import Quick
import Nimble

class CacheTaskSpec: QuickSpec {

  override func spec() {
    describe("CacheTask") {

      describe("#start") {
        it("dispatches the block") {
          let expectation = self.expectationWithDescription(
            "Dispatches Block Expectation")

          let task = CacheTask(processing: {
            expectation.fulfill()
          })
          task.start()


          self.waitForExpectationsWithTimeout(2.0, handler:nil)
        }
      }
    }
  }
}
