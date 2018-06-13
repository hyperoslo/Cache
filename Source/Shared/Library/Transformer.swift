import Foundation

class Transformer<T> {
  let toData: (T) -> Data
  let fromData: (Data) -> T

  init(toData: @escaping (T) -> Data, fromData: @escaping (Data) -> T) {
    self.toData = toData
    self.fromData = fromData
  }
}
