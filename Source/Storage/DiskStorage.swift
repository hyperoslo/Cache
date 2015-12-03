import Foundation

public class DiskStorage: StorageAware {

  public static let prefix = "no.hyper.Cache.Disk"

  public let path: String
  public var maxSize: UInt
  public private(set) var writeQueue: dispatch_queue_t
  public private(set) var readQueue: dispatch_queue_t

  private lazy var fileManager: NSFileManager = {
    let fileManager = NSFileManager()
    return fileManager
    }()

  // MARK: - Initialization

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

  func fileName(key: String) -> String {
    return key.base64()
  }

  func filePath(key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}
