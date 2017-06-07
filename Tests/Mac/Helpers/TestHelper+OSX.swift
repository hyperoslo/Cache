import Cocoa

extension TestHelper {
  static func image(color: NSColor = .red, size: NSSize = .init(width: 1, height: 1)) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
    image.unlockFocus()
    return image
  }
}
