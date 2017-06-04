![Cache](https://github.com/hyperoslo/Cache/blob/master/Resources/CachePresentation.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Cache.svg?style=flat)](https://travis-ci.org/hyperoslo/Cache)
[![Version](https://img.shields.io/cocoapods/v/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Platform](https://img.shields.io/cocoapods/p/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)

## Table of Contents

* [Description](#description)
* [Key features](#key-features)
* [Usage](#usage)
  * [Hybrid cache](#hybrid-cache)
  * [Type safe cache](#type-safe-cache)
  * [SpecializedSyncCache](#specialized-sync-cache)
  * [HybridSyncCache](#hybrid-sync-cache)
  * [Expiry date](#expiry-date)
  * [Enabling Data Protection](#enabling-data-protection)
  * [Cachable protocol](#cachable-protocol)
* [Optional bonuses](#optional-bonuses)
  * [JSON](#json)
  * [Coding](#coding)
  * [DefaultCacheConverter](#defaultcacheconverter)
* [What about images?](#what-about-images)
* [Installation](#installation)
* [Author](#author)
* [Contributing](#contributing)
* [License](#license)

## Description

<img src="https://github.com/hyperoslo/Cache/blob/master/Resources/CacheIcon.png" alt="Cache Icon" align="right" />
**Cache** doesn't claim to be unique in this area, but it's not another monster
library that gives you a god's power.
So don't ask it to fetch something from network or magically set an image from
url to your `UIImageView`.
It does nothing but caching, but it does it well. It offers a good public API
with out-of-box implementations and great customization possibilities.

## Key features

- Generic `Cachable` protocol to be able to cache any type you want.
- `CacheAware` and `StorageAware` protocols to implement different kinds
of key-value cache storages. The basic interface includes methods to add, get
and remove objects by key.
- `SpecializedCache` class to create a type safe cache storage by a given name
for a specified `Cachable`-compliant type.
- `HybridCache` class that works with every kind of `Cachable`-compliant types.
- Flexible `Config` struct which is used in the initialization of `SpecializedCache` and
`HybridCache` classes, based on the concept of having front- and back- caches.
A request to a front cache should be less time and memory consuming (`NSCache` is used
by default here). The difference between front and back caching is that back
caching is used for content that outlives the application life-cycle. See it more
like a convenient way to store user information that should persist across application
launches. Disk cache is the most reliable choice here.
- Possibility to set expiry date + automatic cleanup of expired objects.
- Basic memory and disk cache functionality.
- `Data` encoding and decoding required by `Cachable` protocol are implemented
for `UIImage`, `String`, `JSON` and `Data`.
- iOS and OSX support.

## Usage

### Hybrid cache

`HybridCache` supports storing all kinds of objects, as long as they conform to
the `Cachable` protocol. It's two layered cache (with front and back storages),
as well as `SpecializedCache`.

**Initialization with default configuration**

```swift
let cache = HybridCache(name: "Mix")
```

**Initialization with custom configuration**

```swift
let config = Config(
  // Expiry date that will be applied by default for every added object
  // if it's not overridden in the add(key: object: expiry: completion:) method
  expiry: .date(Date().addingTimeInterval(100000)),
  /// Maximum amount of items to store in memory
  maxObjectsInMemory: 20,
  /// Maximum size of the disk cache storage (in bytes)
  maxDiskSize: 10000,
  // Where to store the disk cache. If nil, it is placed in an automatically generated directory in Caches
  cacheDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                      FileManager.SearchPathDomainMask.userDomainMask,
                                                      true).first! + "/cache-in-documents"
)

let cache = HybridCache(name: "Custom", config: config)
```

**Basic operations**

```swift
let cache = HybridCache(name: "Mix")

// String
cache.add("string", object: "This is a string")

cache.object("string") { (string: String?) in
  print(string) // Prints "This is a string"
}

// JSON
cache.add("jsonDictionary", object: JSON.dictionary(["key": "value"]))

cache.object("jsonDictionary") { (json: JSON?) in
  print(json?.object)
}

// UIImage
cache.add("image", object: UIImage(named: "image.png"))

cache.object("image") { (image: UIImage?) in
  // Use your image
}

// Data
cache.add("data", object: data)

cache.object("data") { (data: Data?) in
  // Use your Data object
}

// Remove an object from the cache
cache.remove("data")

// Clean the cache

cache.clear()
```

### Type safe cache

Initialization with default or custom configuration, basic operations and
working with expiry dates are done exactly in the same way as in `HybridCache`.

**Basic operations**

```swift
// Create an image cache, so it's possible to add only UIImage objects
let cache = SpecializedCache<UIImage>(name: "ImageCache")

// Add objects to the cache
cache.add("image", object: UIImage(named: "image.png"))

// Fetch objects from the cache
cache.object("image") { (image: UIImage?) in
  // Use your image
}

// Remove an object from the cache
cache.remove("image")

// Clean the cache
cache.clear()
```

### HybridSyncCache

**Cache** was born to be async, but if for some reason you need to perform cache
operations synchronously, there is a helper for that.

```swift
let cache = HybridCache(name: "Mix")
let syncCache = HybridSyncCache(cache)

// Add UIImage to cache synchronously
syncCache.add("image", object: UIImage(named: "image.png"))

// Retrieve image from cache synchronously
let image: UIImage? = syncCache.object("image")

// Remove an object from the cache
syncCache.remove("image")

// Clean the cache
syncCache.clear()
```

### SpecializedSyncCache

`SpecializedSyncCache` works exactly in the same way as `HybridSyncCache`, the
only difference is that it's a wrapper around a type safe cache.

```swift
let cache = SpecializedCache<UIImage>(name: "ImageCache")
let syncCache = SpecializedSyncCache(cache)

syncCache.add("image", object: UIImage(named: "image.png"))
let image = syncCache.object("image")
syncCache.remove("image")
syncCache.clear()
```

### Expiry date

```swift
// Default cache expiry date will be applied to the item
cache.add("string", object: "This is a string")

// A provided expiry date will be applied to the item
cache.add("string", object: "This is a string",
  expiry: .date(Date().addingTimeInterval(100000)))

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
try cache.setDirectoryAttributes([FileAttributeKey.immutable: true])
```

### Cachable protocol

Encode and decode methods should be implemented if a type conforms to `Cachable` protocol.

```swift
class User: Cachable {
  typealias CacheType = User

  static func decode(_ data: Data) -> CacheType? {
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
cache.add("jsonDictionary", object: JSON.dictionary(["key": "value"]))

cache.object("jsonDictionary") { (json: JSON?) in
  print(json?.object)
}

cache.add("jsonArray", object: JSON.array([
  ["key1": "value1"],
  ["key2": "value2"]
]))

cache.object("jsonArray") { (json: JSON?) in
  print(json?.object)
}
```

### Coding

`Coding` protocol works in the same way as `NSCoding`, but can be used for
Swift structs and enums. It conforms to `Cachable` and uses `NSKeyedArchiver`
and `NSKeyedUnarchiver` in its default implementations of `encode` and `decode`.

```swift
struct Post {
  let title: String
}

extension Post: Coding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: "title")
  }

  init?(coder aDecoder: NSCoder) {
    guard let title = aDecoder.decodeObject(forKey: "title") as? String else {
      return nil
    }
    self.init(title: title, text: text)
  }
}

// Save and fetch an instance of `Post` struct.
let post = Post(title: "Title")
cache.add("post", object: post) {
  cache.object(key) { (object: Post?) in
    print(object?.title) // Title
  }
}
```

### DefaultCacheConverter

You could use this `Data` encoding and decoding implementation for any kind
of objects, but do it on ***your own risk***. With this approach decoding
***will not work*** if the `Data` length doesn't match the type size. This can commonly
happen if you try to read the data after updates in the type's structure, so
there is a different-sized version of the same type. Also note that `size`
and `size(ofValue:)` may return different values on different devices.

```swift
do {
  object = try DefaultCacheConverter<User>().decode(data)
} catch {}

do {
  data = try DefaultCacheConverter<User>().encode(self)
} catch {}
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
