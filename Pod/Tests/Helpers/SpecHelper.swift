import UIKit

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
