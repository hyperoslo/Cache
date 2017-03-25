/**
 Helper enum to specify a kind of the storage
 */
public enum StorageKind {
  /// Memory storage
  case memory
  /// Disk storage
  case disk
  /// Permanent disk storage
  case permanentDisk
  /// Custom kind of storage by the given name
  case custom(String)

  /// Converts value to appropriate string
  public var name: String {
    let result: String

    switch self {
    case .memory:
      result = "Memory"
    case .disk:
      result = "Disk"
    case .permanentDisk:
        result = "permanentDisk"
    case .custom(let name):
      result = name
    }

    return result
  }
}
