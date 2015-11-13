import Foundation

public enum Kind {
  case Memory, Disk
}

public class Cache<T: Cachable> {

  let name: String
  let kinds: [Kind]
  let expiry: Expiry = .Never

  public init(name: String, kinds: [Kind] = [.Memory, .Disk]) {
    self.name = name
    self.kinds = kinds
  }

  func add(key: String, object: T, expiry: Expiry = .Never, completion: (() -> Void)?) {

  }

  func object(key: String, completion: (object: T?) -> Void) {

  }

  func remove(key: String, completion: (() -> Void)?) {

  }

  func clear(completion: (() -> Void)?) {

  }
}