//: Playground - noun: a place where people can play
import PlaygroundSupport
import UIKit
import Cache

struct Helper {
    static func image(_ color: UIColor = .red, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

  static func data(length: Int) -> Data {
    var buffer = [UInt8](repeating: 0, count: length)
    return Data(bytes: &buffer, count: length)
  }
}

// MARK: - Storage

let diskConfig = DiskConfig(name: "Mix")

let dataStorage = try! Storage(
  diskConfig: diskConfig,
  memoryConfig: MemoryConfig(),
  transformer: TransformerFactory.forData()
)

let stringStorage = dataStorage.transformCodable(ofType: String.self)
let imageStorage = dataStorage.transformImage()
let dateStorage = dataStorage.transformCodable(ofType: Date.self)

// We already have Codable conformances for:
// String, UIImage, NSData and NSDate (just for fun =)

let string = "This is a string"
let image = Helper.image()
let data = Helper.data(length: 64)
let date = Date(timeInterval: 100000, since: Date())

// Add objects to the cache
try stringStorage.setObject(string, forKey: "string")
try imageStorage.setObject(image, forKey: "image")
try dataStorage.setObject(data, forKey: "data")
try dateStorage.setObject(date, forKey: "date")
//
//// Get objects from the cache
let cachedString = try? stringStorage.object(forKey: "string")
print(cachedString as Any)

imageStorage.async.object(forKey: "image") { result in
    if case .value(let image) = result {
        print(image)
    }
}

dataStorage.async.object(forKey: "data") { result in
    if case .value(let data) = result {
        print(data)
    }
}

dateStorage.async.object(forKey: "date") { result in
    if case .value(let date) = result {
        print(date)
    }
}

// Clean the cache
dataStorage.async.removeAll(completion: { (result) in
    if case .value = result {
        print("Cache cleaned")
    }
})

PlaygroundPage.current.needsIndefiniteExecution = true
