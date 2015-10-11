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

  public func add<T: Cachable>(key: String, object: T) {
    if !fileManager.fileExistsAtPath(path) {
      do {
        try fileManager.createDirectoryAtPath(path,
          withIntermediateDirectories: true, attributes: nil)
      } catch _ {}
    }

    fileManager.createFileAtPath(filePath(key),
      contents: object.encode(), attributes: nil)
  }

  public func object<T: Cachable>(key: String) -> T? {
    return nil
  }

  public func remove(key: String) {
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
