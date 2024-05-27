![Cache](https://github.com/hyperoslo/Cache/blob/master/Resources/CachePresentation.png)

[![CI Status](https://circleci.com/gh/hyperoslo/Cache.png)](https://circleci.com/gh/hyperoslo/Cache)
[![Version](https://img.shields.io/cocoapods/v/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Platform](https://img.shields.io/cocoapods/p/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
![Swift](https://img.shields.io/badge/%20in-swift%205-orange.svg)

## Table of Contents

* [Description](#description)
* [Key features](#key-features)
* [Usage](#usage)
  * [Storage](#storage)
  * [Configuration](#configuration)
  * [Sync APIs](#sync-apis)
  * [Async APIs](#async-apis)
  * [Expiry date](#expiry-date)
* [Observations](#observations)
  * [Storage observations](#storage-observations)
  * [Key observations](#key-observations)
* [Handling JSON response](#handling-json-response)
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

Read the story here [Open Source Stories: From Cachable to Generic Storage in Cache](https://medium.com/hyperoslo/open-source-stories-from-cachable-to-generic-storage-in-cache-418d9a230d51)

## Key features

- [x] Work with Swift 4 `Codable`. Anything conforming to `Codable` will be saved and loaded easily by `Storage`.
- [x] Hybrid with memory and disk storage.
- [X] Many options via `DiskConfig` and `MemoryConfig`.
- [x] Support `expiry` and clean up of expired objects.
- [x] Thread safe. Operations can be accessed from any queue.
- [x] Sync by default. Also support Async APIs.
- [x] Extensive unit test coverage and great documentation.
- [x] iOS, tvOS and macOS support.

## Usage

### Storage

`Cache` is built based on [Chain-of-responsibility pattern](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern), in which there are many processing objects, each knows how to do 1 task and delegates to the next one, so can you compose Storages the way you like.

For now the following Storage are supported

- `MemoryStorage`: save object to memory.
- `DiskStorage`: save object to disk.
- `HybridStorage`: save object to memory and disk, so you get persistented object on disk, while fast access with in memory objects.
- `SyncStorage`: blocking APIs, all read and write operations are scheduled in a serial queue, all sync manner.
- `AsyncStorage`: non-blocking APIs, operations are scheduled in an internal queue for serial processing. No read and write should happen at the same time.

Although you can use those Storage at your discretion, you don't have to. Because we also provide a convenient `Storage` which uses `HybridStorage` under the hood, while exposes sync and async APIs through `SyncStorage` and `AsyncStorage`.

All you need to do is to specify the configuration you want with `DiskConfig` and `MemoryConfig`. The default configurations are good to go, but you can customise a lot.


```swift
let diskConfig = DiskConfig(name: "Floppy")
let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let storage = try? Storage(
  diskConfig: diskConfig,
  memoryConfig: memoryConfig,
  transformer: TransformerFactory.forCodable(ofType: User.self) // Storage<String, User>
)
```

### Generic, Type safety and Transformer

All `Storage` now are generic by default, so you can get a type safety experience. Once you create a Storage, it has a type constraint that you don't need to specify type for each operation afterwards.

If you want to change the type, `Cache` offers `transform` functions, look for `Transformer` and `TransformerFactory` for built-in transformers.

```swift
let storage: Storage<String, User> = ...
storage.setObject(superman, forKey: "user")

let imageStorage = storage.transformImage() // Storage<String, UIImage>
imageStorage.setObject(image, forKey: "image")

let stringStorage = storage.transformCodable(ofType: String.self) // Storage<String, String>
stringStorage.setObject("hello world", forKey: "string")
```

Each transformation allows you to work with a specific type, however the underlying caching mechanism remains the same, you're working with the same `Storage`, just with different type annotation. You can also create different `Storage` for each type if you want.

`Transformer` is necessary because the need of serialising and deserialising objects to and from `Data` for disk persistency. `Cache` provides default `Transformer ` for `Data`, `Codable` and `UIImage/NSImage`

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
  /// Fail to perform transformation to or from Data
  case transformerFail
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

`Storage` is sync by default and is `thread safe`, you can access it from any queues. All Sync functions are constrained by `StorageAware` protocol.

```swift
// Save to storage
try? storage.setObject(10, forKey: "score")
try? storage.setObject("Oslo", forKey: "my favorite city", expiry: .never)
try? storage.setObject(["alert", "sounds", "badge"], forKey: "notifications")
try? storage.setObject(data, forKey: "a bunch of bytes")
try? storage.setObject(authorizeURL, forKey: "authorization URL")

// Load from storage
let score = try? storage.object(forKey: "score")
let favoriteCharacter = try? storage.object(forKey: "my favorite city")

// Check if an object exists
let hasFavoriteCharacter = storage.objectExists(forKey: "my favorite city")

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
let entry = try? storage.entry(forKey: "my favorite city")
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
    case .success:
      print("saved successfully")
    case .failure(let error):
      print(error)
  }
}

storage.async.object(forKey: "my favorite city") { result in
  switch result {
    case .success(let city):
      print("my favorite city is \(city)")
    case .failure(let error):
      print(error)
  }
}

storage.async.objectExists(forKey: "my favorite city") { exists in
  if exists {
    print("I have a favorite city")
  }
}

storage.async.removeAll() { result in
  switch result {
    case .success:
      print("removal completes")
    case .failure(let error):
      print(error)
  }
}

storage.async.removeExpiredObjects() { result in
  switch result {
    case .success:
      print("removal completes")
    case .failure(let error):
      print(error)
  }
}
```

#### Swift Concurrency

```swift
do {
  try await storage.async.setObject("Oslo", forKey: "my favorite city")
  print("saved successfully")
} catch {
  print(error)
}

do {
  let city = try await storage.async.object(forKey: "my favorite city")
  print("my favorite city is \(city)")
} catch {
  print(error)
}

let exists = await storage.async.objectExists(forKey: "my favorite city")
if exists {
  print("I have a favorite city")
}

do {
  try await storage.async.remoeAll()
  print("removal completes")
} catch {
  print(error)
}

do {
  try await storage.async.removeExpiredObjects()
  print("removal completes")
} catch {
  print(error)
}
```

### Expiry date

By default, all saved objects have the same expiry as the expiry you specify in `DiskConfig` or `MemoryConfig`. You can overwrite this for a specific object by specifying `expiry` for `setObject`

```swift
// Default expiry date from configuration will be applied to the item
try? storage.setObject("This is a string", forKey: "string")

// A given expiry date will be applied to the item
try? storage.setObject(
  "This is a string",
  forKey: "string",
  expiry: .date(Date().addingTimeInterval(2 * 3600))
)

// Clear expired objects
storage.removeExpiredObjects()
```

## Observations

[Storage](#storage) allows you to observe changes in the cache layer, both on
a store and a key levels. The API lets you pass any object as an observer,
while also passing an observation closure. The observation closure will be
removed automatically when the weakly captured observer has been deallocated.

## Storage observations

```swift
// Add observer
let token = storage.addStorageObserver(self) { observer, storage, change in
  switch change {
  case .add(let key):
    print("Added \(key)")
  case .remove(let key):
    print("Removed \(key)")
  case .removeAll:
    print("Removed all")
  case .removeExpired:
    print("Removed expired")
  }
}

// Remove observer
token.cancel()

// Remove all observers
storage.removeAllStorageObservers()
```

## Key observations

```swift
let key = "user1"

let token = storage.addObserver(self, forKey: key) { observer, storage, change in
  switch change {
  case .edit(let before, let after):
    print("Changed object for \(key) from \(String(describing: before)) to \(after)")
  case .remove:
    print("Removed \(key)")
  }
}

// Remove observer by token
token.cancel()

// Remove observer for key
storage.removeObserver(forKey: key)

// Remove all observers
storage.removeAllKeyObservers()
```

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
    let user = try JSONDecoder.decode(response.result.success, to: User.self)
    try storage.setObject(user, forKey: "most favorite character")
  } catch {
    print(error)
  }
}
```

## What about images

If you want to load image into `UIImageView` or `NSImageView`, then we also have a nice gift for you. It's called [Imaginary](https://github.com/hyperoslo/Imaginary) and uses `Cache` under the hood to make your life easier when it comes to working with remote images.

## Installation

### Cocoapods

**Cache** is available through [CocoaPods](http://cocoapods.org). To install
it or update it, use the following line to your Podfile:

```ruby
pod 'Cache', :git => 'https://github.com/hyperoslo/Cache.git'

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
