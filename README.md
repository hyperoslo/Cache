![Cache](https://github.com/hyperoslo/Cache/blob/master/Resources/CachePresentation.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Cache.svg?style=flat)](https://travis-ci.org/hyperoslo/Cache)
[![Version](https://img.shields.io/cocoapods/v/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Platform](https://img.shields.io/cocoapods/p/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg)

## Table of Contents

* [Description](#description)
* [Key features](#key-features)
* [Usage](#usage)
  * [Configuration](#configuration)
  * [Hybrid cache](#hybrid-cache)
  * [Specialized cache](#specialized-cache)
  * [Expiry date](#expiry-date)
  * [Enabling Data Protection](#enabling-data-protection)
  * [Cachable protocol](#cachable-protocol)
* [Optional bonuses](#optional-bonuses)
  * [JSON](#json)
  * [CacheArray](#cachearray)
* [What about images?](#what-about-images)
* [Installation](#installation)
* [Author](#author)
* [Contributing](#contributing)
* [License](#license)

## Description

<img src="https://github.com/hyperoslo/Cache/blob/master/Resources/CacheIcon.png" alt="Cache Icon" align="right" />

**Cache** doesn't claim to be unique in this area, but it's not another monster
library that gives you a god's power. It does nothing but caching, but it does it well. It offers a good public API
with out-of-box implementations and great customization possibilities. `Cache` utilizes `Codable` in Swift 4 to perform serialization.

## Key features

- [x] Generic `Cachable` protocol to be able to cache any type you want.
- [x] `SpecializedCache` class to create a type safe cache storage by a given
name for a specified `Cachable`-compliant type.
- [x] `HybridCache` class that works with every kind of `Cachable`-compliant
types.
- [x] Flexible `Config` struct which is used in the initialization of
`SpecializedCache` and `HybridCache` classes.
- [x] Possibility to set expiry date + automatic cleanup of expired objects.
- [x] Basic memory and disk cache functionality.
- [x] `Data` encoding and decoding required by `Cachable` protocol are
implemented for `UIImage`, `String`, `JSON` and `Data`.
- [x] Error handling and logs.
- [x] `Coding` protocol brings power of `NSCoding` to Swift structs and enums
- [x] `CacheArray` allows to cache an array of `Cachable` objects.
- [x] Extensive unit test coverage and great documentation.
- [x] iOS, tvOS and macOS support.

## Usage

### Storage

`Cache` is built based on [Chain-of-responsibility pattern](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern), in which there are many processing objects, each knows how to do 1 task and delegate to the next one. But that's just implementation detail. All you need to know is `Storage`, it saves and loads `Codable` objects.

`Storage` has disk storage and an optional memory storage. Memory storage should be less time and memory consuming, while disk storage is used for content that outlives the application life-cycle, see it more like a convenient way to store user information that should persist across application launches.

`DiskConfig` is required to set up disk storage. You can optionally pass `MemoryConfig` to use memory as front storage.


```swift
let diskConfig = DiskConfig(name: "Floppy")
let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let storage = try? Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
```

Error handling is done via `try catch`. `Storage` throws errors in terms of `StorageError`.

```swift
public enum StorageError: Error {
  /// Object can be found
  case notFound
  /// Object is found, but casting to requested type failed
  case typeNotMatch
  /// The file attributes are malformed
  case malformedFileAttributes
  /// Can't perform Decode
  case decodingFailed
  /// Can't perform Encode
  case encodingFailed
  /// The object has been deallocated
  case deallocated
}
```

There can be errors because of disk problem or type mismatch when loading from storage, so if want to handle errors, you need to do `try catch`

```swift
do {
  let storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
} catch {
  print(error)
}
```


### Configuration

Here is how you can play with many configuration options

```swift
let diskConfig = DiskConfig(
  // The name of disk storage, this will be used as folder name within directory
  name: "Floppy",
  // Expiry date that will be applied by default for every added object
  // if it's not overridden in the `setObject(forKey:expiry:)` method
  expiry: .date(Date().addingTimeInterval(2*3600)),
  // Maximum size of the disk cache storage (in bytes)
  maxSize: 10000,
  // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
  directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, 
    appropriateFor: nil, create: true).appendingPathComponent("MyPreferences")
)
```

```swift
let memoryConfig = MemoryConfig(
  // Expiry date that will be applied by default for every added object
  // if it's not overridden in the `setObject(forKey:expiry:)` method
  expiry: .date(Date().addingTimeInterval(2*60)),
  /// The maximum number of objects in memory the cache should hold
  countLimit: 50,
  /// The maximum total cost that the cache can hold before it starts evicting objects
  totalCostLimit: 0
)
```

### Hybrid cache

`HybridCache` supports storing all kinds of objects, as long as they conform to
the `Cachable` protocol.

```swift
// Initialization with default configuration
let cache = HybridCache(name: "Mix")
// Initialization with custom configuration
let customCache = HybridCache(name: "Custom", config: config)
```

**Sync API**

```swift
let cache = HybridCache(name: "Mix")
// Add object to cache
try cache.addObject("This is a string", forKey: "string", expiry: .never)
try cache.addObject(JSON.dictionary(["key": "value"]), "json")
try cache.addObject(UIImage(named: "image.png"), forKey: "image")
try cache.addObject(Data(bytes: [UInt8](repeating: 0, count: 10)), forKey: "data")

// Get object from cache
let string: String? = cache.object(forKey: "string") // "This is a string"
let json: JSON? = cache.object(forKey: "json")
let image: UIImage? = cache.object(forKey: "image")
let data: Data? = cache.object(forKey: "data")

// Get object with expiry date
let entry: CacheEntry<String>? = cache.cacheEntry(forKey: "string")
print(entry?.object) // Prints "This is a string"
print(entry?.expiry.date) // Prints expiry date

// Get total cache size on the disk
let size = try cache.totalDiskSize()

// Remove object from cache
try cache.removeObject(forKey: "data")

// Clear cache
// Pass `true` to keep the existing disk cache directory after removing
// its contents. The default value for `keepingRootDirectory` is `false`.
try cache.clear(keepingRootDirectory: true)

// Clear expired objects
try cache.clearExpired()
```

**Async API**

```swift
// Add object to cache
cache.async.addObject("This is a string", forKey: "string") { error in
  print(error)
}

// Get object from cache
cache.async.object(forKey: "string") { (string: String?) in
  print(string) // Prints "This is a string"
}

// Get object with expiry date
cache.async.cacheEntry(forKey: "string") { (entry: CacheEntry<String>?) in
  print(entry?.object) // Prints "This is a string"
  print(entry?.expiry.date) // Prints expiry date
}

// Remove object from cache
cache.async.removeObject(forKey: "string") { error in
  print(error)
}

// Clear cache
cache.async.clear() { error in
  print(error)
}

// Clear expired objects
cache.async.clearExpired() { error in
  print(error)
}
```

### Specialized cache

`SpecializedCache` is a type safe alternative to `HybridCache` based on generics.
Initialization with default or custom configuration, basic operations and
working with expiry dates are done exactly in the same way as in `HybridCache`.

**Subscript**

```swift
// Create string cache, so it's possible to add only String objects
let cache = SpecializedCache<String>(name: "StringCache")
cache["key"] = "value"
print(cache["key"]) // Prints "value"
cache["key"] = nil
print(cache["key"]) // Prints nil
```

Note that default cache expiry will be used when you use subscript.

**Sync API**

```swift
// Create image cache, so it's possible to add only UIImage objects
let cache = SpecializedCache<UIImage>(name: "ImageCache")

// Add object to cache
try cache.addObject(UIImage(named: "image.png"), forKey: "image")

// Get object from cache
let image = cache.object(forKey: "image")

// Get object with expiry date
let entry = cache.cacheEntry(forKey: "image")
print(entry?.object)
print(entry?.expiry.date) // Prints expiry date

// Get total cache size on the disk
let size = try cache.totalDiskSize()

// Remove object from cache
try cache.removeObject(forKey: "image")

// Clear cache
try cache.clear()

// Clear expired objects
try cache.clearExpired()
```

**Async API**

```swift
// Create string cache, so it's possible to add only String objects
let cache = SpecializedCache<String>(name: "StringCache")

// Add object to cache
cache.async.addObject("This is a string", forKey: "string") { error in
  print(error)
}

// Get object from cache
cache.async.object(forKey: "string") { string in
  print(string) // Prints "This is a string"
}

// Get object with expiry date
cache.async.cacheEntry(forKey: "string") { entry in
  print(entry?.object) // Prints "This is a string"
  print(entry?.expiry.date) // Prints expiry date
}

// Remove object from cache
cache.async.removeObject(forKey: "string") { error in
  print(error)
}

// Clear cache
cache.async.clear() { error in
  print(error)
}

// Clear expired objects
cache.async.clearExpired() { error in
  print(error)
}
```

### Expiry date

```swift
// Default cache expiry date will be applied to the item
try cache.addObject("This is a string", forKey: "string")

// A given expiry date will be applied to the item
try cache.addObject(
  "This is a string",
  forKey: "string"
  expiry: .date(Date().addingTimeInterval(100000))
)

// Clear expired objects
cache.clearExpired()
```

### Enabling data protection

Data protection adds a level of security to files stored on disk by your app in
the app’s container. Follow [App Distribution Guide](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW30) to enable
data protection on iOS, WatchKit Extension, tvOS.

In addition to that you can use a method on `HybridCache` and `SpecializedCache`
to set file protection level (iOS and tvOS only):

```swift
try cache.setFileProtection(.complete)
```

It's also possible to update attributes of the disk cache folder:

```swift
try cache.setDiskCacheDirectoryAttributes([FileAttributeKey.immutable: true])
```

### Cachable protocol

Encode and decode methods should be implemented if a type conforms to `Cachable` protocol.

```swift
struct User: Cachable {
  static func decode(_ data: Data) -> User? {
    var object: User?
    // Decode your object from data
    return object
  }

  func encode() -> Data? {
    var data: Data?
    // Encode your object to data
    return data
  }
}
```

## Optional bonuses

### JSON

JSON is a helper enum that could be `Array([Any])` or `Dictionary([String : Any])`.
Then you could cache `JSON` objects using the same API methods:

```swift
let cache = SpecializedCache<JSON>(name: "JSONCache")

// Dictionary
cache.async.addObject(JSON.dictionary(["key": "value"]), forKey: "dictionary")
cache.async.object(forKey: "dictionary") { json in
  print(json?.object)
}

// Array
cache.async.addObject(JSON.array([["key1": "value1"]]), forKey: "array")
cache.object("array") { json in
  print(json?.object)
}
```

### CacheArray

You can use `CacheArray` to cache an array of `Cachable` objects.

```swift
// SpecializedCache
let cache = SpecializedCache<CacheArray<String>>(name: "User")
let object = CacheArray(elements: ["string1", "string2"])
try cache.addObject(object, forKey: "array")
let array = cache.object(forKey: "array")?.elements
print(array) // Prints ["string1", "string2"]
```

```swift
// HybridCache
let cache = HybridCache(name: "Mix")
let object = CacheArray(elements: ["string1", "string2"])
try cache.addObject(object, forKey: "array")
let array = (cache.object(forKey: "array") as CacheArray<String>?)?.elements
print(array) // Prints ["string1", "string2"]
```


## What about images?

As being said before, `Cache` works with any kind of `Cachable` types, with no
preferences and extra care about specific ones. But don't be desperate, we have
something nice for you. It's called [Imaginary](https://github.com/hyperoslo/Imaginary)
and uses `Cache` under the hood to make you life easier when it comes to working
with remote images.

## Installation

**Cache** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Cache'
```

**Cache** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/Cache"
```

## Author

[Hyper](http://hyper.no) made this with ❤️. If you’re using this library we probably want to [hire you](https://github.com/hyperoslo/iOS-playbook/blob/master/HYPER_RECIPES.md)! Send us an email at ios@hyper.no.

## Contributing

We would love you to contribute to **Cache**, check the [CONTRIBUTING](https://github.com/hyperoslo/Cache/blob/master/CONTRIBUTING.md) file for more info.

## License

**Cache** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/Cache/blob/master/LICENSE.md) file for more info.
