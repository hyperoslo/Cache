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

  public func object<T: Cachable>(key: String, completion: () -> Void) -> T? {
    return nil
  }

  public func remove(key: String, completion: (() -> Void)?) {
    dispatch_async(ioQueue) {
      do {
        try self.fileManager.removeItemAtPath(self.filePath(key))
      } catch _ {}

      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
    }
  }

  public func clear() {
  }

  // MARK: - Helpers

  private func fileName(key: String) -> String {
    return key.base64()
  }

  private func filePath(key: String) -> String {
    return "\(path)/\(fileName(key))"
  }
}
