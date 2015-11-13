import Foundation

public class CacheTask {

  private var block: dispatch_block_t

  init(processing: () -> Void) {
    block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS) {
      processing()
    }
  }

  func start() -> CacheTask {
    dispatch_async(dispatch_get_main_queue(), block)
    return self
  }

  func cancel() {
    dispatch_block_cancel(block)
  }
}
