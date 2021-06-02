//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
/// This file implements SipHash-2-4 and SipHash-1-3
/// (https://131002.net/siphash/).
///
/// This file is based on the reference C implementation, which was released
/// to public domain by:
///
/// * Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
/// * Daniel J. Bernstein <djb@cr.yp.to>
//===----------------------------------------------------------------------===//

import Foundation

extension Hasher {
    // Stolen from https://github.com/apple/swift/blob/master/stdlib/public/core/SipHash.swift
    // in order to replicate the exact format in bytes
    private struct _State {
      private var v0: UInt64 = 0x736f6d6570736575
      private var v1: UInt64 = 0x646f72616e646f6d
      private var v2: UInt64 = 0x6c7967656e657261
      private var v3: UInt64 = 0x7465646279746573
      private var v4: UInt64 = 0
      private var v5: UInt64 = 0
      private var v6: UInt64 = 0
      private var v7: UInt64 = 0
    }

    static func constantAccrossExecutions() -> Hasher {
        let offset = MemoryLayout<Hasher>.size - MemoryLayout<_State>.size
        var hasher = Hasher()
        withUnsafeMutableBytes(of: &hasher) { pointer in
            pointer.baseAddress!.storeBytes(of: _State(), toByteOffset: offset, as: _State.self)
        }
        return hasher
    }
}
