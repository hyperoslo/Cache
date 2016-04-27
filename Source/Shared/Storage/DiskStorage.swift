import Foundation
import CryptoSwift

/**
 File-based cache storage
 */
public class DiskStorage: StorageAware {

  /// Domain prefix
  public static let prefix = "no.hyper.Cache.Disk"

  /// Storage root path
  public let path: String
  /// Maximum size of the cache storage
  public var maxSize: UInt
  /// Queue for write operations
  public private(set) var writeQueue: dispatch_queue_t
  /// Queue for read operations
  public private(set) var readQueue: dispatch_queue_t

  /// File manager to read/write to the disk
  private lazy var fileManager: NSFileManager = {
    let fileManager = NSFileManager()
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
    let cacheName = name.capitalizedString
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
      NSSearchPathDomainMask.UserDomainMask, true)

    path = "\(paths.first!)/\(DiskStorage.prefix).\(cacheName)"
    writeQueue = dispatch_queue_create("\(DiskStorage.prefix).\(cacheName).WriteQueue",
      DISPATCH_QUEUE_SERIAL)
    readQueue = dispatch_queue_create("\(DiskStorage.prefix).\(cacheName).ReadQueue",
      DISPATCH_QUEUE_SERIAL)
  }

  // MARK: - CacheAware

  /**
   Saves passed object on the disk.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter object: Object that needs to be cached
   - Parameter expiry: Expiration date for the cached object
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func add<T: Cachable>(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      if !weakSelf.fileManager.fileExistsAtPath(weakSelf.path) {
        do {
          try weakSelf.fileManager.createDirectoryAtPath(weakSelf.path,
            withIntermediateDirectories: true, attributes: nil)
        } catch {}
      }

      do {
        let filePath = weakSelf.filePath(key)
        weakSelf.fileManager.createFileAtPath(filePath,
          contents: object.encode(), attributes: nil)
        try weakSelf.fileManager.setAttributes(
          [NSFileModificationDate : expiry.date],
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
  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    dispatch_async(readQueue) { [weak self] in
      guard let weakSelf = self else {
        completion(object: nil)
        return
      }

      let filePath = weakSelf.filePath(key)
      var cachedObject: T?

      if let data = NSData(contentsOfFile: filePath)  {
        cachedObject = T.decode(data) as? T
      }

      completion(object: cachedObject)
    }
  }

  /**
   Removes the object from the cache by the given key.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func remove(key: String, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        try weakSelf.fileManager.removeItemAtPath(weakSelf.filePath(key))
      } catch {}

      completion?()
    }
  }

  /**
   Removes the object from the cache if it's expired.

   - Parameter key: Unique key to identify the object in the cache
   - Parameter completion: Completion closure to be called when the task is done
   */
  public func removeIfExpired(key: String, completion: (() -> Void)?) {
    let path = filePath(key)

    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        let attributes = try weakSelf.fileManager.attributesOfItemAtPath(path)
        if let expiryDate = attributes[NSFileModificationDate] as? NSDate
          where expiryDate.inThePast {
            try weakSelf.fileManager.removeItemAtPath(weakSelf.filePath(key))
        }
      } catch {}

      completion?()
    }
  }

  /**
   Clears the cache storage.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clear(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      do {
        try weakSelf.fileManager.removeItemAtPath(weakSelf.path)
      } catch {}

      completion?()
    }
  }

  /**
   Clears all expired objects.

   - Parameter completion: Completion closure to be called when the task is done
   */
  public func clearExpired(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else {
        completion?()
        return
      }

      let URL = NSURL(fileURLWithPath: weakSelf.path)
      let resourceKeys = [NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey]
      var objects = [(URL: NSURL, resourceValues: [NSObject: AnyObject])]()
      var URLsToDelete = [NSURL]()
      var totalSize: UInt = 0

      guard let fileEnumerator = weakSelf.fileManager.enumeratorAtURL(URL, includingPropertiesForKeys: resourceKeys,
        options: .SkipsHiddenFiles, errorHandler: nil), URLs = fileEnumerator.allObjects as? [NSURL] else {
          completion?()
          return
      }

      for fileURL in URLs {
        do {
          let resourceValues = try fileURL.resourceValuesForKeys(resourceKeys)

          guard (resourceValues[NSURLIsDirectoryKey] as? NSNumber)?.boolValue == false else {
            continue
          }

          if let expiryDate = resourceValues[NSURLContentModificationDateKey] as? NSDate
            where expiryDate.inThePast {
              URLsToDelete.append(fileURL)
              continue
          }

          if let fileSize = resourceValues[NSURLTotalFileAllocatedSizeKey] as? NSNumber {
            totalSize += fileSize.unsignedLongValue
            objects.append((URL: fileURL, resourceValues: resourceValues))
          }
        } catch {}
      }

      for fileURL in URLsToDelete {
        do {
          try weakSelf.fileManager.removeItemAtURL(fileURL)
        } catch {}
      }

      if weakSelf.maxSize > 0 && totalSize > weakSelf.maxSize {
        let targetSize = weakSelf.maxSize / 2

        let sortedFiles = objects.sort {
          let time1 = ($0.resourceValues[NSURLContentModificationDateKey] as? NSDate)?.timeIntervalSince1970
          let time2 = ($1.resourceValues[NSURLContentModificationDateKey] as? NSDate)?.timeIntervalSince1970
          return time1 > time2
        }

        for file in sortedFiles {
          do {
            try weakSelf.fileManager.removeItemAtURL(file.URL)
          } catch {}

          if let fileSize = file.resourceValues[NSURLTotalFileAllocatedSizeKey] as? NSNumber {
            totalSize -= fileSize.unsignedLongValue
          }

          if totalSize < targetSize {
            break
          }
        }
      }

      completion?()
    }
  }

  // MARK: - Helpers

  /**
   Builds file name from the key.

   - Parameter key: Unique key to identify the object in the cache
   */
  func fileName(key: String) -> String {
    if let digest = key.dataUsingEncoding(NSUTF8StringEncoding)?.md5() {
      var string = ""
      var byte: UInt8 = 0

      for i in 0 ..< digest.length {
        digest.getBytes(&byte, range: NSMakeRange(i, 1))
        string += String(format: "%02x", byte)
      }

      return string
    } else {
      return key.base64()
    }
  }

  /**
   Builds file path from the key.

   - Parameter key: Unique key to identify the object in the cache
   */
  func filePath(key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}
