//
//  PermanentDiskStorage.swift
//  Cache
//
//  Created by Pantelis Zirinis on 25/03/2017.
//  Copyright © 2017 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

public class PermanentDiskStorage: DiskStorage {
    
    public required init(name: String, maxSize: UInt = 0) {
        
        let cacheName = name.capitalized
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let path = "\(paths.first!)/\(DiskStorage.prefix).\(cacheName)"
        super.init(name: name, maxSize: maxSize, path: path)
    }

}
