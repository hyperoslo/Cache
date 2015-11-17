import Foundation

// MARK: - Cachable

extension NSData: Cachable {

  public typealias CacheType = NSData

  public static func decode(data: NSData) -> CacheType? {
    return data
  }

  public func encode() -> NSData? {
    return self
  }
}

// MARK: - Helpers

extension NSData {

  enum Format {
    case PNG, JPEG, Other
  }

  var format: Format {
    var result: Format = .Other
    let pngBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    let jpgBytes: [UInt8] = [0xFF, 0xD8, 0xFF]

    var buffer = [UInt8](count: 8, repeatedValue: 0)
    getBytes(&buffer, length: 8)

    if buffer == pngBytes {
      result = .PNG
    } else if buffer[0...2] == jpgBytes[0...2] {
      result = .JPEG
    }

    return result
  }
}
