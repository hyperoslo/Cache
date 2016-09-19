import UIKit

struct SpecHelper {

  static var user: User {
    return User(firstName: "John", lastName: "Snow")
  }

  static func data(_ length : Int) -> Data {
    var buffer = [UInt8](repeating: 0, count: length)
    return Data(bytes: UnsafePointer<UInt8>(&buffer), count: length)
  }

  static func image(_ color: UIColor = UIColor.red,
    size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
      let context = UIGraphicsGetCurrentContext()

      context?.setFillColor(color.cgColor)
      context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return image!
  }
}
