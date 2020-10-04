
import Foundation

extension URL {
  /// Returns the file size of the file at the given `URL` in bytes
  var fileSize: Int? {
    do {
      let file = try self.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
      return file.totalFileAllocatedSize ?? file.fileAllocatedSize
    } catch {
      return nil
    }
  }
}
