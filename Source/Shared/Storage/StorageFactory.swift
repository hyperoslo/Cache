//
//  StorageFactory.swift
//  Cache
//
//  Created by Khoa Pham on 13.06.2018.
//  Copyright © 2018 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

public extension Storage2 {
  func supportImage() -> Storage2<Image> {
    fatalError()
  }

  func supportCodable() -> Storage2<Codable> {
    fatalError()
  }
}
