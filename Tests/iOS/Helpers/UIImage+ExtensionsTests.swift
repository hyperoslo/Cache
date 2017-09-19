import UIKit

extension UIImage {
  func isEqualToImage(_ image: UIImage) -> Bool {
    let data = normalizedData()
    return data == image.normalizedData()
  }

  func normalizedData() -> Data {
    let pixelSize = CGSize(
      width : size.width * scale,
      height : size.height * scale
    )

    UIGraphicsBeginImageContext(pixelSize)
    draw(
      in: CGRect(x: 0, y: 0, width: pixelSize.width,
      height: pixelSize.height)
    )

    let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return drawnImage!.cgImage!.dataProvider!.data! as Data
  }
}
