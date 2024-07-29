import Foundation

public extension Optional {
  func unwrapOrThrow(error: any Error) throws -> Wrapped {
    if let value = self {
      return value
    } else {
      throw error
    }
  }
}
