public enum StorageChange: Equatable {
  case add(key: String)
  case remove(key: String)
  case removeAll
  case removeExpired
}

public func == (lhs: StorageChange, rhs: StorageChange) -> Bool {
  switch (lhs, rhs) {
  case (.add(let key1), .add(let key2)), (.remove(let key1), .remove(let key2)):
    return key1 == key2
  case (.removeAll, .removeAll), (.removeExpired, .removeExpired):
    return true
  default:
    return false
  }
}
