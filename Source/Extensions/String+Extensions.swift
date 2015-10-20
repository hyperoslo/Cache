import Foundation

extension String {

  func base64() -> String {
    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return self }
    return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
  }
}
