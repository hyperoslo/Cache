//: Playground - noun: a place where people can play

import UIKit
import Cache

struct Helper {

  static func image(color: UIColor = UIColor.redColor(),
    size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
      let context = UIGraphicsGetCurrentContext()

      CGContextSetFillColorWithColor(context, color.CGColor)
      CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))

      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return image
  }

  static func data(length : Int) -> NSData {
    var buffer = [UInt8](count:length, repeatedValue:0)
    return NSData(bytes:&buffer, length: length)
  }
}

// MARK: - Cache

let cache = HybridCache(name: "Mix")

// There is no need to implement Cachable protocol here.
// We already have default implementations for:
// String, JSON, UIImage, NSData and NSDate (just for fun =)

let string = "This is a string"
let json = JSON.Dictionary(["key": "value"])
let image = Helper.image()
let data = Helper.data(64)
let date = NSDate(timeInterval: 100000, sinceDate: NSDate())

// Add objects to the cache

cache.add("string", object: string)
cache.add("json", object: json)
cache.add("image", object: image)
cache.add("data", object: data)
cache.add("date", object: date)

// Get objects from the cache

cache.object("string") { (string: String?) in
  print(string)
}

cache.object("json") { (json: JSON?) in
  print(json?.object)
}

cache.object("image") { (image: UIImage?) in
  print(image)
}

cache.object("data") { (data: NSData?) in
  print(data)
}

cache.object("date") { (date: NSDate?) in
  print(date)
}

// Remove an object from the cache

cache.remove("data")

// Clean the cache

cache.clear()
