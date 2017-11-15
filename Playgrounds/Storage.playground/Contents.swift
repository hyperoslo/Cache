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

let storage = try! Storage(diskConfig: diskConfig)

// We already have Codable conformances for:
// String, UIImage, NSData and NSDate (just for fun =)

let string = "This is a string"
let image = Helper.image()
let imageWrapper = ImageWrapper(image: image)
let newImage = imageWrapper.image
let data = Helper.data(length: 64)
let date = Date(timeInterval: 100000, since: Date())

// Add objects to the cache
try storage.setObject(string, forKey: "string")
try storage.setObject(imageWrapper, forKey: "imageWrapper")
try storage.setObject(data, forKey: "data")
try storage.setObject(date, forKey: "date")
//
//// Get objects from the cache
let cachedString = try? storage.object(ofType: String.self, forKey: "string")
print(cachedString)

storage.async.object(ofType: ImageWrapper.self, forKey: "imageWrapper") { result in
    if case .value(let imageWrapper) = result {
        let image = imageWrapper.image
        print(image)
    }
}

storage.async.object(ofType: Data.self, forKey: "data") { result in
    if case .value(let data) = result {
        print(data)
    }
}

storage.async.object(ofType: Data.self, forKey: "data") { result in
    if case .value(let data) = result {
        print(data)
    }
}

storage.async.object(ofType: Date.self, forKey: "date") { result in
    if case .value(let date) = result {
        print(date)
    }
}

// Clean the cache
try storage.async.removeAll(completion: { (result) in
    if case .value = result {
        print("Cache cleaned")
    }
})

PlaygroundPage.current.needsIndefiniteExecution = true
