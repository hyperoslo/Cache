import Quick
import Nimble

class DiskCacheSpec: QuickSpec {

  override func spec() {
    describe("DiskCache") {
      let name = "Test"
      let object = User(firstName: "John", lastName: "Snow")
      var cache: DiskCache!
      var fileManager = NSFileManager()

      beforeEach {
        cache = DiskCache(name: name)
      }

      afterEach {
        try! fileManager.removeItemAtPath(cache.path)
      }

      describe("#path") {
        it("returns the correct path") {
          let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
          let path = "\(paths.first!)/\(cache.prefix).\(name.capitalizedString)"

          expect(cache.path).to(equal(path))
        }
      }

      describe("#add") {
        it("creates cache directory") {
          cache.add("testkey", object: object)

          let fileExist = fileManager.fileExistsAtPath(cache.path)
          expect(fileExist).to(beTrue())
        }

        it("saves object for specified key") {
          let version = app.version()
          expect(version).to(match("^0.\\d.\\d$"))
        }
      }

      describe("#object") {
        it("returns the correct text") {
          let author = app.author()
          expect(author).to(equal("Mr. Vadym Markov"))
        }
      }
    }
  }
}
