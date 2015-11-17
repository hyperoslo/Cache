import Foundation

enum CacheError: ErrorType {
  case Add(String)
  case Get(String)
  case Remove(String)
  case RemoveIfExpired(String)
  case Clear(String)
}
