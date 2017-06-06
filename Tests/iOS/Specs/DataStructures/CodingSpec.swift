import Quick
import Nimble
@testable import Cache

private struct Post {
  let title: String
  let text: String
}

extension Post: Coding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: "title")
    aCoder.encode(text, forKey: "text")
  }

  init?(coder aDecoder: NSCoder) {
    guard let title = aDecoder.decodeObject(forKey: "title") as? String else {
      return nil
    }
    guard let text = aDecoder.decodeObject(forKey: "text") as? String else {
      return nil
    }
    self.init(title: title, text: text)
  }
}

class CodingSpec: QuickSpec {
  override func spec() {
    describe("Coding") {
      var storage: DiskStorage!
      let fileManager = FileManager()
      let key = "post"
      var object: Post!

      beforeEach {
        storage = DiskStorage(name: "Storage")
        object = Post(title: "Title", text: "Text")
      }

      afterEach {
        do {
          try fileManager.removeItem(atPath: storage.path)
        } catch {}
      }
      
      describe("Encoding and decoding") {
        it("resolves cached object") {
          try! storage.add(key, object: object)
          let receivedObject: Post? = try! storage.object(key)
          expect(receivedObject?.title).to(equal("Title"))
          expect(receivedObject?.text).to(equal("Text"))
        }
      }
    }
  }
}
