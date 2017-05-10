public struct ObjectMetadata {
    let expiry: Expiry
}

extension ObjectMetadata: Equatable {}

public func ==(lhs: ObjectMetadata, rhs: ObjectMetadata) -> Bool {
    return lhs.expiry.date == rhs.expiry.date
}
