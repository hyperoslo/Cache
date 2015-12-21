public enum StorageKind {
  case Memory
  case Disk
  case Custom(String)

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