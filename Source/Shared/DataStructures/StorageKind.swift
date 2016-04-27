/**
 Helper enum to specify a kind of the storage
 */
public enum StorageKind {
  /// Memory storage
  case Memory
  /// Disk storage
  case Disk
  /// Custom kind of storage by the given name
  case Custom(String)

  /// Converts value to appropriate string
  public var name: String {
    let result: String

    switch self {
    case .Memory:
      result = "Memory"
    case .Disk:
      result = "Disk"
    case .Custom(let name):
      result = name
    }

    return result
  }
}
