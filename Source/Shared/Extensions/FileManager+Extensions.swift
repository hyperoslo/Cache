
import Foundation

extension FileManager {
  /**
   Calculates the size of the directory at the provided `URL`
   - parameter url: the directory url
   - returns: the size of the provided directory in bytes
   */
  public func sizeOfDirectory(at url: URL) -> Int? {
    guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: [], options: [], errorHandler: { _, _ -> Bool in
      return false
    }) else {
      return nil
    }
    var size = 0
    for case let url as URL in enumerator {
      size += url.fileSize ?? 0
    }
    return size
  }
}
