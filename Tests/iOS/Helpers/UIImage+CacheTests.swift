import UIKit

extension UIImage {

  func isEqualToImage(image: UIImage) -> Bool {
    let data = normalizedData()
    return data.isEqualToData(image.normalizedData())
  }

  func normalizedData() -> NSData {
    let pixelSize = CGSize(
      width : size.width * scale,
      height : size.height * scale)

    UIGraphicsBeginImageContext(pixelSize)
    drawInRect(CGRect(x: 0, y: 0, width: pixelSize.width,
      height: pixelSize.height))

    let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    #if swift(>=2.3)
    return CGDataProviderCopyData(CGImageGetDataProvider(drawnImage!.CGImage!)!)!
    #else
    return CGDataProviderCopyData(CGImageGetDataProvider(drawnImage.CGImage))!
    #endif
  }
}
