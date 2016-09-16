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
      let context = UIGraphicsGetCurrentContext()

      #if swift(>=2.3)
      CGContextSetFillColorWithColor(context!, color.CGColor)
      CGContextFillRect(context!, CGRectMake(0, 0, size.width, size.height))
      #else
      CGContextSetFillColorWithColor(context, color.CGColor)
      CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
      #endif

      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      #if swift(>=2.3)
      return image!
      #else
      return image
      #endif
  }
}
