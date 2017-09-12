import Foundation

struct PrimitiveWrapper<T: Codable>: Codable {
  let value: T

  init(value: T) {
    self.value = value
  }
}
