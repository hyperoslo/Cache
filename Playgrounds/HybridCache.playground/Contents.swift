//: Playground - noun: a place where people can play
import PlaygroundSupport
import UIKit
import Cache

struct Helper {
  static func image(color: UIColor = .red, size: CGSize = .init(width: 1, height: 1), opaque: Bool = false) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image!
  }

  static func data(length : Int) -> Data {
    var buffer = [UInt8](repeating:0, count:length)
    return Data(bytes:&buffer, count: length)
  }
}

// MARK: - Cache

let cache = HybridCache(name: "Mix")

// There is no need to implement Cachable protocol here.
// We already have default implementations for:
// String, JSON, UIImage, NSData and NSDate (just for fun =)

let string = "This is a string"
let json = JSON.dictionary(["key": "value"])
let image = Helper.image()
let data = Helper.data(length: 64)
let date = Date(timeInterval: 100000, since: Date())

// Add objects to the cache

try cache.addObject(string, forKey: "string")
try cache.addObject(json, forKey: "json")
try cache.addObject(image, forKey: "image")
try cache.addObject(data, forKey: "data")
try cache.addObject(date, forKey: "date")

// Get objects from the cache
let cachedObject: String? = cache.object(forKey: "string")
print(cachedObject)

cache.async.object(forKey: "json") { (json: JSON?) in
  print(json?.object ?? "")
}

cache.async.object(forKey: "image") { (image: UIImage?) in
  print(image ?? "")
}

cache.async.object(forKey: "data") { (data: Data?) in
  print(data ?? "'")
}

cache.async.object(forKey: "date") { (date: Date?) in
  print(date ?? "")
}

// Remove an object from the cache
try cache.removeObject(forKey: "data")

// Clean the cache
try cache.clear()

PlaygroundPage.current.needsIndefiniteExecution = true
