//
//  IdleStorage.swift
//  Cache-iOS
//
//  Created by Yakimovich, Kirill on 11/20/17.
//  Copyright © 2017 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

final class IdleStorage {}

extension IdleStorage: StorageAware {
  public func entry<T: Codable>(ofType type: T.Type, forKey key: String) throws -> Entry<T> {
    throw StorageError.notFound
  }

  public func removeObject(forKey key: String) throws {}

  public func setObject<T: Codable>(_ object: T, forKey key: String,
                                    expiry: Expiry? = nil) throws {}

  public func removeAll() throws {}

  public func removeExpiredObjects() throws {}
}
