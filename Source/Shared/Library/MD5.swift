
// https://github.com/onevcat/Kingfisher/blob/master/Sources/Utility/String%2BMD5.swift

import CommonCrypto


public func MD5(_ input: String) -> String {
    guard let data = input.data(using: .utf8) else {
        return input
    }
    var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
    #if swift(>=5.0)
    _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
    }
    #else
    _ = data.withUnsafeBytes { bytes in
        return CC_MD5(bytes, CC_LONG(data.count), &digest)
    }
    #endif
    
    return digest.map { String(format: "%02x", $0) }.joined()
}


