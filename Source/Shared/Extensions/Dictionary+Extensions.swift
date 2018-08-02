import Foundation

extension Dictionary where Key == UUID {
  mutating func insert(_ value: Value) -> UUID {
    let id = UUID()
    self[id] = value
    return id
  }
}
