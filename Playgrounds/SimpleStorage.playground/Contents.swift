//: Playground - noun: a place where people can play
import PlaygroundSupport
import UIKit
import Cache

struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String

    var name: String {
        return "\(firstName) \(lastName)"
    }
}

let diskConfig = DiskConfig(name: "UserCache")
let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let storage = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)

let user = User(id: 1, firstName: "John", lastName: "Snow")
let key = "\(user.id)"

// Add objects to the cache
try storage.setObject(user, forKey: key)

// Fetch object from the cache
storage.async.object(ofType: User.self, forKey: key) { result in
    switch result {
    case .value(let user):
        print(user.name)
    case .error(let error):
        print(error)
    }
}

// Remove object from the cache
try storage.removeObject(forKey: key)

// Try to fetch removed object from the cache
storage.async.object(ofType: User.self, forKey: key) { result in
    switch result {
    case .value(let user):
        print(user.name)
    case .error:
        print("no such object")
    }
}

// Clear cache
try storage.removeAll()

PlaygroundPage.current.needsIndefiniteExecution = true
