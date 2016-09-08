import UIKit

struct SpecHelper {

  static var user: User {
    return User(firstName: "John", lastName: "Snow")
  }

  static func data(length : Int) -> NSData {
    var buffer = [UInt8](count:length, repeatedValue:0)
    return NSData(bytes:&buffer, length: length)
  }

  static func image(color: UIColor = UIColor.redColor(),
    size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
      #if swift(>=2.3)
          let context = UIGraphicsGetCurrentContext()!
      #else
          let context = UIGraphicsGetCurrentContext()
      #endif

      CGContextSetFillColorWithColor(context, color.CGColor)
      CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))

      #if swift(>=2.3)
          let image = UIGraphicsGetImageFromCurrentImageContext()!
      #else
          let image = UIGraphicsGetImageFromCurrentImageContext()
      #endif
      UIGraphicsEndImageContext()

      return image
  }
}
