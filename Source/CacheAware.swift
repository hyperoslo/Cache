import Foundation

public class CacheTask {
  private var block: dispatch_block_t

  init(processing: () -> Void) {
    block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
      processing()
    }
  }

  func cancel() {
    dispatch_block_cancel(block)
  }
}

public protocol CacheAware {
  var prefix: String { get }
  var path: String { get }
  var maxSize: UInt { get set }

  init(name: String)

  func add<T: Cachable>(key: String, object: T, completion: (() -> Void)?) -> CacheTask?
  func object<T: Cachable>(key: String, completion: (object: T?) -> Void) -> CacheTask?
  func remove(key: String, completion: (() -> Void)?) -> CacheTask?
  func clear() -> CacheTask?
}
