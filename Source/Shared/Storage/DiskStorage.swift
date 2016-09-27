import Foundation
import CryptoSwift

/**
 File-based cache storage
 */
public final class DiskStorage: StorageAware {

  /// Domain prefix
  public static let prefix = "no.hyper.Cache.Disk"

  /// Storage root path
  public let path: String
  /// Maximum size of the cache storage
  public var maxSize: UInt
  /// Queue for write operations
  public fileprivate(set) var writeQueue: DispatchQueue
  /// Queue for read operations
  public fileprivate(set) var readQueue: DispatchQueue

  /// File manager to read/write to the disk
  fileprivate lazy var fileManager: FileManager = {
    let fileManager = FileManager()
    return fileManager
  }()

  // MARK: - Initialization

  /**
   Creates a new disk storage.

   - Parameter name: A name of the storage
   - Parameter maxSize: Maximum size of the cache storage
   */
  public required init(name: String, maxSize: UInt = 0) {
    self.maxSize = maxSize
    let cacheName = name.capitalized
    let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
      FileManager.SearchPathDomainMask.userDomainMask, true)

    path = "\(paths.first!)/\(DiskStorage.prefix).\(cacheName)"
    writeQueue = DispatchQueue(label: "\(DiskStorage.prefix).\(cacheName).WriteQueue",
      attributes: [])
    readQueue = DispatchQueue(label: "\(DiskStorage.prefix).\(cacheName).ReadQueue",
      attributes: [])
  }

  // MARK: - CacheAware

  /**
   Saves passed object on the disk.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(_ key: String, object: T, expiry: Expiry = .never, completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if !weakSelf.fileManager.fileExists(atPath: weakSelf.path) {
        do {
          try weakSelf.fileManager.createDirectory(atPath: weakSelf.path,
            withIntermediateDirectories: true, attributes: nil)
        } catch {}
      }

      do {
        let filePath = weakSelf.filePath(key)
        weakSelf.fileManager.createFile(atPath: filePath,
          contents: object.encode() as Data?, attributes: nil)
        try weakSelf.fileManager.setAttributes(
          [FileAttributeKey.modificationDate : expiry.date],
          ofItemAtPath: filePath)
      } catch {}

      completion?()
    }
  }

  /**
   Tries to retrieve the object from the disk storage.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure returns object or nil
   */
  public func object<T: Cachable>(_ key: String, completion: @escaping (_ object: T?) -> Void) {
    readQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion(nil)
        return
      }

      let filePath = weakSelf.filePath(key)
      var cachedObject: T?

      if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
        cachedObject = T.decode(data) as? T
      }

      completion(cachedObject)
    }
  }

  /**
   Removes the object from the cache by the given key.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(_ key: String, completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        try weakSelf.fileManager.removeItem(atPath: weakSelf.filePath(key))
      } catch {}

      completion?()
    }
  }

  /**
   Removes the object from the cache if it's expired.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func removeIfExpired(_ key: String, completion: (() -> Void)?) {
    let path = filePath(key)

    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        let attributes = try weakSelf.fileManager.attributesOfItem(atPath: path)
        if let expiryDate = attributes[FileAttributeKey.modificationDate] as? Date,
          expiryDate.inThePast {
            try weakSelf.fileManager.removeItem(atPath: weakSelf.filePath(key))
        }
      } catch {}

      completion?()
    }
  }

  /**
   Clears the cache storage.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(_ completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        try weakSelf.fileManager.removeItem(atPath: weakSelf.path)
      } catch {}

      completion?()
    }
  }

  typealias ResourceObject = (url: Foundation.URL, resourceValues: [AnyHashable: Any])

  /**
   Clears all expired objects.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(_ completion: (() -> Void)? = nil) {
    writeQueue.async { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let URL = Foundation.URL(fileURLWithPath: weakSelf.path)
      let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey, .totalFileAllocatedSizeKey]
      var objects = [ResourceObject]()
      var URLsToDelete: [Foundation.URL] = []
      var totalSize: UInt = 0

      guard let fileEnumerator = weakSelf.fileManager.enumerator(at: URL, includingPropertiesForKeys: resourceKeys,
        options: .skipsHiddenFiles, errorHandler: nil), let URLs = fileEnumerator.allObjects as? [Foundation.URL] else {
          completion?()
          return
      }

      for fileURL in URLs {
        do {
          let resourceValues = try (fileURL as NSURL).resourceValues(forKeys: resourceKeys)

          guard (resourceValues[URLResourceKey.isDirectoryKey] as? NSNumber)?.boolValue == false else {
            continue
          }

          if let expiryDate = resourceValues[URLResourceKey.contentModificationDateKey] as? Date,
            expiryDate.inThePast {
              URLsToDelete.append(fileURL)
              continue
          }

          if let fileSize = resourceValues[URLResourceKey.totalFileAllocatedSizeKey] as? NSNumber {
            totalSize += fileSize.uintValue
            objects.append((url: fileURL, resourceValues: resourceValues))
          }
        } catch {}
      }

      for fileURL in URLsToDelete {
        do {
          try weakSelf.fileManager.removeItem(at: fileURL)
        } catch {}
      }

      weakSelf.removeResourceObjects(objects, totalSize: totalSize)
      completion?()
    }
  }

  /**
   Removes expired resource objects.

   - Parameter objects: Resource objects to remove
   - Parameter totalSize: Total size
   */
  func removeResourceObjects(_ objects: [ResourceObject], totalSize: UInt) {
    guard maxSize > 0 && totalSize > maxSize else {
      return
    }

    var totalSize = totalSize
    let targetSize = maxSize / 2

    let sortedFiles = objects.sorted {
      let time1 = ($0.resourceValues[URLResourceKey.contentModificationDateKey] as? Date)?.timeIntervalSince1970
      let time2 = ($1.resourceValues[URLResourceKey.contentModificationDateKey] as? Date)?.timeIntervalSince1970
      return time1 > time2
    }

    for file in sortedFiles {
      do {
        try fileManager.removeItem(at: file.url)
      } catch {}

      if let fileSize = file.resourceValues[URLResourceKey.totalFileAllocatedSizeKey] as? NSNumber {
        totalSize -= fileSize.uintValue
      }

      if totalSize < targetSize {
        break
      }
    }
  }

  // MARK: - Helpers

  /**
   Builds file name from the key.

   - Parameter key: Unique key to identify the object in the cache
   - Returns: A md5 or base64 string
   */
  func fileName(_ key: String) -> String {
    if let digest = key.data(using: String.Encoding.utf8)?.md5() {
      var string = ""
      for byte in digest {
        string += String(format:"%02x", byte)
      }

      return string
    } else {
      return key.base64()
    }
  }

  /**
   Builds file path from the key.

   - Parameter key: Unique key to identify the object in the cache
   - Returns: A string path based on key
   */
  func filePath(_ key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
