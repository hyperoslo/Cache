//
//  AllEntriesFinder.swift
//  Cache-iOS
//
//  Created by dushantsw on 2018-09-09.
//  Copyright © 2018 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

/// A protocol user for load all the entries and objects
protocol AllEntriesRetriever {
  associatedtype T

  /**
   Loads all the entries from the disk cache. It does not
   load or store entries on retrieval into memory as sync
   issues may occur.
   - Returns: An array of Entry for associated type T
   */
  func entries() throws -> [Entry<T>]
}

extension AllEntriesRetriever {
  /**
   Loads all the entries and extracts all the non-nil objects
   - Returns: An array
   */
  func objects() throws -> [T] {
    return try entries().compactMap({ $0.object })
  }
}
