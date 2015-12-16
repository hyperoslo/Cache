# Cache

[![CI Status](http://img.shields.io/travis/hyperoslo/Cache.svg?style=flat)](https://travis-ci.org/hyperoslo/Cache)
[![Version](https://img.shields.io/cocoapods/v/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)
[![Platform](https://img.shields.io/cocoapods/p/Cache.svg?style=flat)](http://cocoadocs.org/docsets/Cache)

## Description

**Cache** doesn't claim to be unique in this area, but it's not another monster
library that gives you a god's power.
So don't ask it to fetch something from network or magically set an image from
URL to your `UIImageView`.
It does nothing but caching, but it does it well, having everything you expect
from this kind of library. It offers a good public API with out-of-box
implementations and great customization possibilities.   

## Key features
- Generic `Cachable` protocol to be able to cache any type of objects
- `CacheAware` and `StorageAware` protocol to implement different kinds
of key-value cache storages. The basic interface includes methods to add, get
and remove objects by key.
- `Cache` class to create a strict cache storage by a given name for specified
`Cachable`-compliant type.
- `HybridCache` class which is able to work with every kind of `Cachable`-compliant objects.
- Flexible `Config` struct which is used in the initialization of `Cache` and
`HybridCache` classes, based on the concept of having front- and back- caches.
A request to a front cache should be less time and memory consuming (`NSCache` is used
by default here). On the other hand, back cache should be more permanent and
independent from the life cycle of application, because it's more like backup
solution to store your data (Disk cache is one of the reliable approaches here).
- `StorageFactory` - a place to register and retrieve your cache storage by type
- Possibility to set expiry date + automatic cleanup of expired objects
- Basic memory and disk cache functionality
- Scalability, you are free to add as many cache storages as you want
(if default implementations of memory and disk caches don't fit your purpose for some reason)
- `NSData` encoding and decoding required by `Cachable` protocol are implemented
for `UIImage`, `String`, `JSON` and `NSData`.

## Usage

```swift

```

### Optional bonus

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

Hyper Interaktiv AS, ios@hyper.no

## License

**Cache** is available under the MIT license. See the LICENSE file for more info.
