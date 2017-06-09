import Foundation
import SwiftHash

/**
 File-based cache storage.
 */
final class DiskStorage: StorageAware {
  enum Error: Swift.Error {
    case fileEnumeratorFailed
  }

  /// Storage root path
  let path: String
  /// Maximum size of the cache storage
  let maxSize: UInt
  /// File manager to read/write to the disk
  fileprivate let fileManager = FileManager()

  // MARK: - Initialization

  /**
   Creates a new disk storage.
   - Parameter name: A name of the storage
   - Parameter maxSize: Maximum size of the cache storage
   - Parameter cacheDirectory: (optional) A folder to store the disk cache contents. Defaults to a prefixed directory in Caches
   */
  required init(name: String, maxSize: UInt = 0, cacheDirectory: String? = nil) {
    self.maxSize = maxSize

    do {
      if let cacheDirectory = cacheDirectory {
        path = cacheDirectory
      } else {
        let url = try fileManager.url(
          for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        path = url.appendingPathComponent(name, isDirectory: true).path
      }

      try createDirectory()
    } catch {
      fatalError("Failed to find or get access to caches directory: \(error)")
    }
  }

  /// Calculates total disk cache size.
  func totalSize() throws -> UInt64 {
    var size: UInt64 = 0
    let contents = try fileManager.contentsOfDirectory(atPath: path)
    for pathComponent in contents {
      let filePath = (path as NSString).appendingPathComponent(pathComponent)
      let attributes = try fileManager.attributesOfItem(atPath: filePath)
      if let fileSize = attributes[.size] as? UInt64 {
        size += fileSize
      }
    }
    return size
  }

  // MARK: - CacheAware

  /**
   Saves passed object on the disk.
   - Parameter object: Object that needs to be cached
   - Parameter key: Unique key to identify the object in the cache
   - Parameter expiry: Expiration date for the cached object
   */
  func addObject<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry = .never) throws {
    let filePath = makeFilePath(for: key)
    fileManager.createFile(atPath: filePath, contents: object.encode(), attributes: nil)
    try fileManager.setAttributes([.modificationDate: expiry.date], ofItemAtPath: filePath)
  }

  /**
   Gets information about the cached object.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Cached object or nil if not found
   */
  func object<T: Cachable>(forKey key: String) throws -> T? {
    return (try cacheEntry(forKey: key) as CacheEntry<T>?)?.object
  }

  /**
   Get cache entry which includes object with metadata.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: Object wrapper with metadata or nil if not found
   */
  func cacheEntry<T: Cachable>(forKey key: String) throws -> CacheEntry<T>? {
    let filePath = makeFilePath(for: key)
    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
    let attributes = try fileManager.attributesOfItem(atPath: filePath)

    guard let object = T.decode(data) as? T, let date = attributes[.modificationDate] as? Date else {
      return nil
    }

    return CacheEntry(
      object: object,
      expiry: Expiry.date(date)
    )
  }

  /**
   Removes the object from the cache by the given key.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObject(forKey key: String) throws {
    try fileManager.removeItem(atPath: makeFilePath(for: key))
  }

  /**
   Removes the object from the cache if it's expired.
   - Parameter key: Unique key to identify the object in the cache
   */
  func removeObjectIfExpired(forKey key: String) throws {
    let filePath = makeFilePath(for: key)
    let attributes = try fileManager.attributesOfItem(atPath: filePath)
    if let expiryDate = attributes[.modificationDate] as? Date, expiryDate.inThePast {
      try fileManager.removeItem(atPath: filePath)
    }
  }

  /**
   Removes all objects from the cache storage.
   */
  func clear() throws {
    try fileManager.removeItem(atPath: path)
  }

  func createDirectory() throws {
    if !fileManager.fileExists(atPath: path) {
      try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
  }

  private typealias ResourceObject = (url: Foundation.URL, resourceValues: [AnyHashable: Any])

  /**
   Clears all expired objects.
   */
  func clearExpired() throws {
    let storageURL = URL(fileURLWithPath: path)
    let resourceKeys: [URLResourceKey] = [
      .isDirectoryKey,
      .contentModificationDateKey,
      .totalFileAllocatedSizeKey
    ]
    var resourceObjects = [ResourceObject]()
    var filesToDelete = [URL]()
    var totalSize: UInt = 0
    let fileEnumerator = fileManager.enumerator(
      at: storageURL,
      includingPropertiesForKeys: resourceKeys,
      options: .skipsHiddenFiles,
      errorHandler: nil
    )

    guard let urlArray = fileEnumerator?.allObjects as? [URL] else {
      throw Error.fileEnumeratorFailed
    }

    for url in urlArray {
      let resourceValues = try (url as NSURL).resourceValues(forKeys: resourceKeys)
      guard (resourceValues[.isDirectoryKey] as? NSNumber)?.boolValue == false else {
        continue
      }

      if let expiryDate = resourceValues[.contentModificationDateKey] as? Date, expiryDate.inThePast {
        filesToDelete.append(url)
        continue
      }

      if let fileSize = resourceValues[.totalFileAllocatedSizeKey] as? NSNumber {
        totalSize += fileSize.uintValue
        resourceObjects.append((url: url, resourceValues: resourceValues))
      }
    }

    // Remove expired objects
    for url in filesToDelete {
      try fileManager.removeItem(at: url)
    }

    // Remove objects if storage size exceeds max size
    try removeResourceObjects(resourceObjects, totalSize: totalSize)
  }

  /**
   Removes objects if storage size exceeds max size.
   - Parameter objects: Resource objects to remove
   - Parameter totalSize: Total size
   */
  private func removeResourceObjects(_ objects: [ResourceObject], totalSize: UInt) throws {
    guard maxSize > 0 && totalSize > maxSize else {
      return
    }

    var totalSize = totalSize
    let targetSize = maxSize / 2

    let sortedFiles = objects.sorted {
      let key = URLResourceKey.contentModificationDateKey
      let time1 = ($0.resourceValues[key] as? Date)?.timeIntervalSinceReferenceDate
      let time2 = ($1.resourceValues[key] as? Date)?.timeIntervalSinceReferenceDate
      return time1 > time2
    }

    for file in sortedFiles {
      try fileManager.removeItem(at: file.url)
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
   - Returns: A md5 string
   */
  func makeFileName(for key: String) -> String {
    return MD5(key)
  }

  /**
   Builds file path from the key.
   - Parameter key: Unique key to identify the object in the cache
   - Returns: A string path based on key
   */
  func makeFilePath(for key: String) -> String {
    return "\(path)/\(makeFileName(for: key))"
  }
}

extension DiskStorage {
  #if os(iOS) || os(tvOS)
  /**
   Data protection is used to store files in an encrypted format on disk and to decrypt them on demand.
   - Parameter type: File protection type
   */
  func setFileProtection( _ type: FileProtectionType) throws {
    try setDirectoryAttributes([FileAttributeKey.protectionKey: type])
  }
  #endif

  /**
   Sets attributes on the disk cache folder.
   - Parameter attributes: Directory attributes
   */
  func setDirectoryAttributes(_ attributes: [FileAttributeKey : Any]) throws {
    try fileManager.setAttributes(attributes, ofItemAtPath: path)
  }
}

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
