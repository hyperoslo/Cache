import Foundation

public class DiskCache: CacheAware {

  public let prefix = "no.hyper.Cache.Disk"
  public let ioQueueName = "no.hyper.Cache.Disk.IOQueue."
  public let path: String
  public var maxSize: UInt = 0

  private var fileManager: NSFileManager!
  private let ioQueue: dispatch_queue_t

  // MARK: - Initialization

  public required init(name: String) {
    let cacheName = name.capitalizedString
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
      NSSearchPathDomainMask.UserDomainMask, true)

    path = "\(paths.first!)/\(prefix).\(cacheName)"
    ioQueue = dispatch_queue_create("\(ioQueueName).\(cacheName)", DISPATCH_QUEUE_SERIAL)

    dispatch_sync(ioQueue) {
      self.fileManager = NSFileManager()
    }
  }

  // MARK: - CacheAware

  public func add<T: Cachable>(key: String, object: T, start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }

      if !weakSelf.fileManager.fileExistsAtPath(weakSelf.path) {
        do {
          try weakSelf.fileManager.createDirectoryAtPath(weakSelf.path,
            withIntermediateDirectories: true, attributes: nil)
        } catch _ {}
      }

      weakSelf.fileManager.createFileAtPath(
        weakSelf.filePath(key),
        contents: object.encode(), attributes: nil)

      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
    }

    return start ? task.start() : task
  }

  public func object<T: Cachable>(key: String, start: Bool = true, completion: (object: T?) -> Void) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }

      dispatch_async(weakSelf.ioQueue) {
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

    return start ? task.start() : task
  }

  public func remove(key: String, start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }

      dispatch_async(weakSelf.ioQueue) {
        do {
          try weakSelf.fileManager.removeItemAtPath(weakSelf.filePath(key))
        } catch _ {}

        dispatch_async(dispatch_get_main_queue()) {
          completion?()
        }
      }
    }

    return start ? task.start() : task
  }

  public func clear(start: Bool = true, completion: (() -> Void)? = nil) -> CacheTask? {
    let task = CacheTask { [weak self] in
      guard let weakSelf = self else { return }

      dispatch_async(weakSelf.ioQueue) {
        do {
          try weakSelf.fileManager.removeItemAtPath(weakSelf.path)
        } catch _ {}

        dispatch_async(dispatch_get_main_queue()) {
          completion?()
        }
      }
    }

    return start ? task.start() : task
  }

  // MARK: - Helpers

  func fileName(key: String) -> String {
    return key.base64()
  }

  func filePath(key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}
