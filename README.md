![Cache](https://github.com/hyperoslo/Cache/blob/master/Resources/CachePresentation.png)

[![CI Status](https://circleci.com/gh/hyperoslo/Cache.png)](https://circleci.com/gh/hyperoslo/Cache)
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
  * [Storage](#storage)
  * [Configuration](#configuration)
  * [Sync APIs](#sync-apis)
  * [Async APIS](#async-apis)
  * [Expiry date](#expiry-date)
* [What about images?](#what-about-images)
* [Handling JSON response](#handling-json-response)
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

- [x] Work with Swift 4 `Codable`. Anything conforming to `Codable` will be saved and loaded easily by `Storage`.
- [X] Disk storage by default. Optionally using `memory storage` to enable hybrid.
- [X] Many options via `DiskConfig` and `MemoryConfig`.
- [x] Support `expiry` and clean up of expired objects.
- [x] Thread safe. Operations can be accessed from any queue.
- [x] Sync by default. Also support Async APIs.
- [X] Store images via `ImageWrapper`.
- [x] Extensive unit test coverage and great documentation.
- [x] iOS, tvOS and macOS support.

## Usage

### Storage

`Cache` is built based on [Chain-of-responsibility pattern](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern), in which there are many processing objects, each knows how to do 1 task and delegates to the next one. But that's just implementation detail. All you need to know is `Storage`, it saves and loads `Codable` objects.

`Storage` has disk storage and an optional memory storage. Memory storage should be less time and memory consuming, while disk storage is used for content that outlives the application life-cycle, see it more like a convenient way to store user information that should persist across application launches.

`DiskConfig` is required to set up disk storage. You can optionally pass `MemoryConfig` to use memory as front storage.


```swift
let diskConfig = DiskConfig(name: "Floppy")
let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let storage = try? Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
```

#### Codable types

`Storage` supports any objects that conform to [Codable](https://developer.apple.com/documentation/swift/codable) protocol. You can [make your own things conform to Codable](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) so that can be saved and loaded from `Storage`.

The supported types are

- Primitives like `Int`, `Float`, `String`, `Bool`, ...
- Array of primitives like `[Int]`, `[Float]`, `[Double]`, ...
- Set of primitives like `Set<String>`, `Set<Int>`, ...
- Simply dictionary like `[String: Int]`, `[String: String]`, ...
- `Date`
- `URL`
- `Data`

#### Error handling

Error handling is done via `try catch`. `Storage` throws errors in terms of `StorageError`.

```swift
public enum StorageError: Error {
  /// Object can not be found
  case notFound
  /// Object is found, but casting to requested type failed
  case typeNotMatch
  /// The file attributes are malformed
  case malformedFileAttributes
  /// Can't perform Decode
  case decodingFailed
  /// Can't perform Encode
  case encodingFailed
  /// The storage has been deallocated
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
    appropriateFor: nil, create: true).appendingPathComponent("MyPreferences"),
  // Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
  protectionType: .complete
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

On iOS, tvOS we can also specify `protectionType` on `DiskConfig` to add a level of security to files stored on disk by your app in the app’s container. For more information, see [FileProtectionType](https://developer.apple.com/documentation/foundation/fileprotectiontype)

### Sync APIs

`Storage` is sync by default and is `thead safe`, you can access it from any queues. All Sync functions are constrained by `StorageAware` protocol.

```swift
// Save to storage
try? storage.setObject(10, forKey: "score")
try? storage.setObject("Oslo", forKey: "my favorite city", expiry: .never)
try? storage.setObject(["alert", "sounds", "badge"], forKey: "notifications")
try? storage.setObject(data, forKey: "a bunch of bytes")
try? storage.setObject(authorizeURL, forKey: "authorization URL")

// Load from storage
let score = try? storage.object(ofType: Int.self, forKey: "score")
let favoriteCharacter = try? storage.object(ofType: String.self, forKey: "my favorite city")

// Check if an object exists
let hasFavoriteCharacter = try? storage.existsObject(ofType: String.self, forKey: "my favorite city")

// Remove an object in storage
try? storage.removeObject(forKey: "my favorite city")

// Remove all objects
try? storage.removeAll()

// Remove expired objects
try? storage.removeExpiredObjects()
```

#### Entry

There is time you want to get object together with its expiry information and meta data. You can use `Entry`

```swift
let entry = try? storage.entry(ofType: String.self, forKey: "my favorite city")
print(entry?.object)
print(entry?.expiry)
print(entry?.meta)
```

`meta` may contain file information if the object was fetched from disk storage.

#### Custom Codable

`Codable` works for simple dictionary like `[String: Int]`, `[String: String]`, ... It does not work for `[String: Any]` as `Any` is not `Codable` conformance, it will raise `fatal error` at runtime. So when you get json from backend responses, you need to convert that to your custom `Codable` objects and save to `Storage` instead.

```swift
struct User: Codable {
  let firstName: String
  let lastName: String
}

let user = User(fistName: "John", lastName: "Snow")
try? storage.setObject(user, forKey: "character")
```

### Async APIs

In `async` fashion, you deal with `Result` instead of `try catch` because the result is delivered at a later time, in order to not block the current calling queue. In the completion block, you either have `value` or `error`. 

You access Async APIs via `storage.async`, it is also thread safe, and you can use Sync and Async APIs in any order you want. All Async functions are constrained by `AsyncStorageAware` protocol.

```swift
storage.async.setObject("Oslo", forKey: "my favorite city") { result in
  switch result {
    case .value:
      print("saved successfully")
    case .error(let error):
      print(error)
    }
  }
}

storage.async.object(ofType: String.self, forKey: "my favorite city") { result in
  switch result {
    case .value(let city):
      print("my favorite city is \(city)")
    case .error(let error):
      print(error)
    }
  }
}

storage.async.existsObject(ofType: String.self, forKey: "my favorite city") { result in
  if case .value(let exists) = result, exists {
    print("I have a favorite city")
  }
}

storage.async.removeAll() { result in
  print("removal completes")
}

storage.async.removeExpiredObjects() { result in
  print("removal completes")
}
```

### Expiry date

By default, all saved objects have the same expiry as the expiry you specify in `DiskConfig` or `MemoryConfig`. You can overwrite this for a specific object by specifying `expiry` for `setObject`

```swift
// Default cexpiry date from configuration will be applied to the item
try? storage.setObject("This is a string", forKey: "string")

// A given expiry date will be applied to the item
try? storage.setObject(
  "This is a string",
  forKey: "string"
  expiry: .date(Date().addingTimeInterval(2 * 3600))
)

// Clear expired objects
storage.removeExpiredObjects()
```

## What about images?

As you may know, `NSImage` and `UIImage` don't conform to `Codable` by default. To make it play well with `Codable`, we introduce `ImageWrapper`, so you can save and load images like

```swift
let wrapper = ImageWrapper(image: starIconImage)
try? storage.setObject(wrapper, forKey: "star")

let icon = try? storage.object(ofType: ImageWrapper.self, forKey: "star").image
```

If you want to load image into `UIImageView` or `NSImageView`, then we also have a nice gift for you. It's called [Imaginary](https://github.com/hyperoslo/Imaginary) and uses `Cache` under the hood to make you life easier when it comes to working with remote images.

## Handling JSON response

Most of the time, our use case is to fetch some json from backend, display it while saving the json to storage for future uses. If you're using libraries like [Alamofire](https://github.com/Alamofire/Alamofire) or [Malibu](https://github.com/hyperoslo/Malibu), you mostly get json in the form of dictionary, string, or data.

`Storage` can persist `String` or `Data`. You can even save json to `Storage` using `JSONArrayWrapper` and `JSONDictionaryWrapper`, but we prefer persisting the strong typed objects, since those are the objects that you will use to display in UI. Furthermore, if the json data can't be converted to strongly typed objects, what's the point of saving it ? 😉

You can use these extensions on `JSONDecoder` to decode json dictionary, string or data to objects.

```swift
let user = JSONDecoder.decode(jsonString, to: User.self)
let cities = JSONDecoder.decode(jsonDictionary, to: [City].self)
let dragons = JSONDecoder.decode(jsonData, to: [Dragon].self)
```

This is how you perform object converting and saving with `Alamofire`

```swift
Alamofire.request("https://gameofthrones.org/mostFavoriteCharacter").responseString { response in
  do {
    let user = try JSONDecoder.decode(response.result.value, to: User.self)
    try storage.setObject(user, forKey: "most favorite character")
  } catch {
    print(error)
  }
}
```

## Installation

### Cocoapods

**Cache** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Cache'
```

### Carthage

**Cache** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/Cache"
```

You also need to add `SwiftHash.framework` in your [copy-frameworks](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) script.

## Author

- [Hyper](http://hyper.no) made this with ❤️
- Inline MD5 implementation from [SwiftHash](https://github.com/onmyway133/SwiftHash) 

## Contributing

We would love you to contribute to **Cache**, check the [CONTRIBUTING](https://github.com/hyperoslo/Cache/blob/master/CONTRIBUTING.md) file for more info.

## License

**Cache** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/Cache/blob/master/LICENSE.md) file for more info.
