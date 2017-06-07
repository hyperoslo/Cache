import UIKit

extension TestHelper {
  static func image(_ color: UIColor = .red, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image!
  }
}
