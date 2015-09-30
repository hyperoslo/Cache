import Foundation

public class DiskCache: CacheAware {
  public let prefix = "no.hyper.Cache.Disk"
  public let path: String
  public var maxSize: UInt = 0

  private var fileManager: NSFileManager!

  public required init(name: String) {
    let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
      NSSearchPathDomainMask.UserDomainMask, true)
    path = "\(paths.first!)/\(prefix)\(name)"
  }

  // MARK: - CacheAware

  public func add<T: AnyObject>(key: String, object: T) {
  }

  public func object<T: AnyObject>(key: String) -> T? {
    return nil
  }

  public func remove(key: String) {
  }

  public func clear() {
  }
}
