#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit
  public typealias Image = UIImage
#elseif os(watchOS)

#elseif os(OSX)
  import AppKit
  public typealias Image = NSImage
#endif
