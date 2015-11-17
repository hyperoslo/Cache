import UIKit
import Foundation

struct User {

  var firstName: String
  var lastName: String

  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
}

extension User: Cachable {

  typealias CacheType = User

  static func decode(data: NSData) -> CacheType? {
    var object: User?

    do {
      object = try DefaultCacheConverter<User>().decode(data)
    } catch {}

    return object
  }

  func encode() -> NSData? {
    var data: NSData?

    do {
      data = try DefaultCacheConverter<User>().encode(self)
    } catch {}

    return data
  }
}

struct SpecHelper {

  static var user: User {
    return User(firstName: "John", lastName: "Snow")
  }

  static func image(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
    let context = UIGraphicsGetCurrentContext()

    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
  }
}
