import Foundation

public enum Kind {
  case Memory, Disk
}

public class Cache<T: Cachable> {

  let name: String
  let kinds: [Kind]

  public init(name: String, kinds: [Kind] = [.Memory, .Disk]) {
    self.name = name
    self.kinds = kinds
  }
}