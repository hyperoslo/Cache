import Cocoa

struct SpecHelper {

  static func image(color: NSColor = NSColor.redColor(), size: NSSize = CGSize(width: 1, height: 1)) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    color.drawSwatchInRect(NSMakeRect(0, 0, size.width, size.height))
    image.unlockFocus()
    return image
  }
}
