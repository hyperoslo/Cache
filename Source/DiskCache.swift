import Foundation

public class DiskCache: CacheAware {

  public static let prefix = "no.hyper.Cache.Disk"

  public let path: String
  public var maxSize: UInt = 0
  public private(set) var writeQueue: dispatch_queue_t
  public private(set) var readQueue: dispatch_queue_t

  private lazy var fileManager: NSFileManager = {
    let fileManager = NSFileManager()
    return fileManager
    }()

  // MARK: - Initialization

  public required init(name: String) {
    let cacheName = name.capitalizedString
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
      NSSearchPathDomainMask.UserDomainMask, true)

    path = "\(paths.first!)/\(DiskCache.prefix).\(cacheName)"
    writeQueue = dispatch_queue_create("\(DiskCache.prefix).\(cacheName).WriteQueue",
      DISPATCH_QUEUE_SERIAL)
    readQueue = dispatch_queue_create("\(DiskCache.prefix).\(cacheName).ReadQueue",
      DISPATCH_QUEUE_SERIAL)
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, completion: (() -> Void)? = nil) {
    if !fileManager.fileExistsAtPath(path) {
      do {
        try fileManager.createDirectoryAtPath(path,
          withIntermediateDirectories: true, attributes: nil)
      } catch _ {}
    }

    fileManager.createFileAtPath(filePath(key),
      contents: object.encode(), attributes: nil)

    dispatch_async(dispatch_get_main_queue()) {
      completion?()
    }
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) {
    dispatch_async(readQueue) { [weak self] in
      guard let weakSelf = self else { return }

      let filePath = weakSelf.filePath(key)
      var cachedObject: T?
      if let data = NSData(contentsOfFile: filePath)  {
        cachedObject = T.decode(data)
      }

      dispatch_async(dispatch_get_main_queue()) {
        completion(object: cachedObject)
      }
    }
  }

  public func remove(key: String, completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else { return }

      do {
        try weakSelf.fileManager.removeItemAtPath(weakSelf.filePath(key))
      } catch _ {}

      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
    }
  }

  public func clear(completion: (() -> Void)? = nil) {
    dispatch_async(writeQueue) { [weak self] in
      guard let weakSelf = self else { return }

      do {
        try weakSelf.fileManager.removeItemAtPath(weakSelf.path)
      } catch _ {}

      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
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
