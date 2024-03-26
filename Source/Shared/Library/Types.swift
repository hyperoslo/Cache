#if canImport(UIKit)
  import UIKit
  public typealias Image = UIImage

#elseif os(OSX)
  import AppKit
  public typealias Image = NSImage
#endif
