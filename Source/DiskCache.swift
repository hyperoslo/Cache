import Foundation

public class DiskCache: CacheAware {

  public var prefix = "no.hyper.Cache.Disk"
  public var ioQueueName = "no.hyper.Cache.Disk.IOQueue."
  public let path: String
  public var maxSize: UInt = 0

  private var fileManager: NSFileManager!
  private let ioQueue: dispatch_queue_t

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

  public func add<T: Cachable>(key: String, object: T, completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
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
  }

  public func object<T: Cachable>(key: String, completion: (object: T?) -> Void) -> CacheTask? {
    return nil
  }

  public func remove(key: String, completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
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
  }

  public func clear(completion: (() -> Void)? = nil) -> CacheTask? {
    return CacheTask { [weak self] in
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
  }

  // MARK: - Helpers

  private func fileName(key: String) -> String {
    return key.base64()
  }

  private func filePath(key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}
