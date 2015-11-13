import Foundation

public class Cache<T: Cachable> {

  let name: String

  public init(name: String) {
    self.name = name
  }
}