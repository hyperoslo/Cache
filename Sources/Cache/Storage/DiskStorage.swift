import Foundation
import SwiftHash
#if os(Linux)
    import Glibc

let system_glob = Glibc.glob
#else
    import Darwin

let system_glob = Darwin.glob
#endif

/**
 File-based cache storage.
 */
final class DiskStorage: StorageAware {
    enum Error: Swift.Error {
        case fileEnumeratorFailed
    }

    /// Storage root path
    let path: String
    /// Maximum size of the cache storage
    let maxSize: UInt
    /// File manager to read/write to the disk
    fileprivate let fileManager = FileManager.default

    // MARK: - Initialization

    /**
     Creates a new disk storage.
     - Parameter name: A name of the storage
     - Parameter maxSize: Maximum size of the cache storage
     - Parameter cacheDirectory: (optional) A folder to store the disk cache contents. Defaults to a prefixed directory in Caches
     */
    required init(name: String, maxSize: UInt = 0, cacheDirectory: String? = nil) {
        self.maxSize = maxSize

        do {
            if let cacheDirectory = cacheDirectory {
                path = cacheDirectory
            } else {
                #if os(Linux)
                    let url = URL(fileURLWithPath: fileManager.currentDirectoryPath + "/.cache")
                #else
                    let url = try fileManager.url(
                        for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true
                    )
                #endif
                path = url.appendingPathComponent(name, isDirectory: true).path
            }

            try createDirectory()
        } catch {
            fatalError("Failed to find or get access to caches directory: \(error)")
        }
    }

    /// Calculates total disk cache size.
    func totalSize() throws -> UInt64 {
        var size: UInt64 = 0
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for pathComponent in contents {
            let filePath: String
            if path.last == "/" {
                filePath = path + pathComponent
            } else {
                filePath = path + "/" + pathComponent
            }
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? UInt64 {
                size += fileSize
            }
        }
        return size
    }

    // MARK: - CacheAware

    /**
     Saves passed object on the disk.
     - Parameter object: Object that needs to be cached
     - Parameter key: Unique key to identify the object in the cache
     - Parameter expiry: Expiration date for the cached object
     */
    func addObject<T: Cachable>(_ object: T, forKey key: String, expiry: Expiry = .never) throws {
        let filePath = makeFilePath(for: key)
        let _ = fileManager.createFile(atPath: filePath, contents: object.encode(), attributes: nil)
        #if os(Linux)
            var tv = timeval(tv_sec: Int(expiry.date.timeIntervalSince1970), tv_usec: 0)
            utimes(filePath, &tv)
        #else
            try fileManager.setAttributes([.modificationDate: expiry.date], ofItemAtPath: filePath)
        #endif
    }

    /**
     Gets information about the cached object.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: Cached object or nil if not found
     */
    func object<T: Cachable>(forKey key: String) throws -> T? {
        return (try cacheEntry(forKey: key) as CacheEntry<T>?)?.object
    }

    /**
     Get cache entry which includes object with metadata.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: Object wrapper with metadata or nil if not found
     */
    func cacheEntry<T: Cachable>(forKey key: String) throws -> CacheEntry<T>? {
        let filePath = makeFilePath(for: key)
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let attributes = try fileManager.attributesOfItem(atPath: filePath)

        guard let object = T.decode(data) as? T, let date = attributes[.modificationDate] as? Date else {
            return nil
        }

        return CacheEntry(
            object: object,
            expiry: Expiry.date(date)
        )
    }

    /**
     Removes the object from the cache by the given key.
     - Parameter key: Unique key to identify the object in the cache
     */
    func removeObject(forKey key: String) throws {
        try fileManager.removeItem(atPath: makeFilePath(for: key))
    }

    /**
     Removes the object from the cache if it's expired.
     - Parameter key: Unique key to identify the object in the cache
     */
    func removeObjectIfExpired(forKey key: String) throws {
        let filePath = makeFilePath(for: key)
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        if let expiryDate = attributes[.modificationDate] as? Date, expiryDate.inThePast {
            try fileManager.removeItem(atPath: filePath)
        }
    }

    /**
     Removes all objects from the cache storage.
     */
    func clear() throws {
        try fileManager.removeItem(atPath: path)
    }

    func createDirectory() throws {
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private typealias ResourceObject = (url: Foundation.URL, modification: Date?, size: UInt?)

    /**
     Clears all expired objects.
     */
    func clearExpired() throws {
        let storageURL = URL(fileURLWithPath: path)
        let resourceKeys: [URLResourceKey] = [
            .isDirectoryKey,
            .contentModificationDateKey,
            .totalFileAllocatedSizeKey
        ]
        var resourceObjects = [ResourceObject]()
        var filesToDelete = [URL]()
        var totalSize: UInt = 0
        #if os(Linux)
            let urlArray = glob(path + "/*")
        #else
            let fileEnumerator = fileManager.enumerator(
                at: storageURL,
                includingPropertiesForKeys: resourceKeys,
                options: .skipsHiddenFiles,
                errorHandler: nil
            )

            guard let urlArray = fileEnumerator?.allObjects as? [URL] else {
                throw Error.fileEnumeratorFailed
            }
        #endif

        for url in urlArray {
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: url.absoluteString, isDirectory: &isDir) else {
                continue
            }
            #if os(Linux)
                guard isDir == false else {
                    continue
                }
            #else
                guard isDir.boolValue == false else {
                    continue
                }
            #endif

            #if os(Linux)
                var stat_struct = stat()
                let modif = Date(timeIntervalSince1970: TimeInterval(exactly: stat_struct.st_mtim.tv_sec)!)
                if modif.inThePast {
                    filesToDelete.append(url)
                }
                stat(url.absoluteString, &stat_struct)
                let size = UInt(stat_struct.st_size)
                totalSize -= size
            #else
                let fileAttributes = try fileManager.attributesOfItem(atPath: url.absoluteString)
                let modif: Date? = fileAttributes[FileAttributeKey.modificationDate] as? Date
                if let expiryDate = modif, expiryDate.inThePast {
                    filesToDelete.append(url)
                }

                var size: UInt? = nil
                if let fileSize = fileAttributes[FileAttributeKey.size] as? UInt64 {
                    size = UInt(fileSize)
                    totalSize -= size!

                    resourceObjects.append((url: url, modification: modif, size: size!))
                }
            #endif
            resourceObjects.append((url: url, modification: modif, size: size))
        }

        // Remove expired objects
        for url in filesToDelete {
            try fileManager.removeItem(at: url)
        }

        // Remove objects if storage size exceeds max size
        try removeResourceObjects(resourceObjects, totalSize: totalSize)
    }

    private func glob(_ pattern: String) -> [URL] {
        var gt = glob_t()
        let cPattern = strdup(pattern)
        defer {
            globfree(&gt)
            free(cPattern)
        }

        let flags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
        if system_glob(cPattern, flags, nil, &gt) == 0 {
            #if os(Linux)
                let matchc = gt.gl_pathc
            #else
                let matchc = gt.gl_matchc
            #endif
            return (0..<Int(matchc)).flatMap { index in
                if let path = String(validatingUTF8: gt.gl_pathv[index]!) {
                    return URL(fileURLWithPath: path)
                }

                return nil
            }
        }

        // GLOB_NOMATCH
        return []
    }

    /**
     Removes objects if storage size exceeds max size.
     - Parameter objects: Resource objects to remove
     - Parameter totalSize: Total size
     */
    private func removeResourceObjects(_ objects: [ResourceObject], totalSize: UInt) throws {
        guard maxSize > 0 && totalSize > maxSize else {
            return
        }

        var totalSize = totalSize
        let targetSize = maxSize / 2

        let sortedFiles = objects.sorted {
            let time1 = $0.modification?.timeIntervalSinceReferenceDate
            let time2 = $1.modification?.timeIntervalSinceReferenceDate
            return time1 > time2
        }

        for file in sortedFiles {
            try fileManager.removeItem(at: file.url)
            if let fileSize = file.size {
                totalSize -= UInt(fileSize)
            }

            if totalSize < targetSize {
                break
            }
        }
    }

    // MARK: - Helpers

    /**
     Builds file name from the key.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: A md5 string
     */
    func makeFileName(for key: String) -> String {
        return MD5(key)
    }

    /**
     Builds file path from the key.
     - Parameter key: Unique key to identify the object in the cache
     - Returns: A string path based on key
     */
    func makeFilePath(for key: String) -> String {
        return "\(path)/\(makeFileName(for: key))"
    }
}

extension DiskStorage {
    /**
     Sets attributes on the disk cache folder.
     - Parameter attributes: Directory attributes
     */
    func setDirectoryAttributes(_ attributes: [FileAttributeKey : Any]) throws {
        try fileManager.setAttributes(attributes, ofItemAtPath: path)
    }
}

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
