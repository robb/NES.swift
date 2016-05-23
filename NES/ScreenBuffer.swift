import Foundation

internal typealias RGBColor = (red: UInt8, green: UInt8, blue: UInt8)

internal struct ScreenBuffer {
    static let bitsPerComponent = 8

    static let componensPerPixel = 4

    static let height = 240

    static let width = 256

    var pixels: Array<UInt8>

    init() {
        let count = ScreenBuffer.componensPerPixel * ScreenBuffer.width * ScreenBuffer.height

        pixels = Array<UInt8>(count: count, repeatedValue: 0x00)
    }

    private func calculateBaseOffset(x: Int, _ y: Int) -> Int {
        precondition(x < ScreenBuffer.width)
        precondition(y < ScreenBuffer.height)

        return x * ScreenBuffer.componensPerPixel
             + y * ScreenBuffer.componensPerPixel * ScreenBuffer.width
    }

    subscript(x: Int, y: Int) -> RGBColor {
        get {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let base = calculateBaseOffset(x, y)

            return (pixels[base], pixels[base + 1], pixels[base + 2])
        }
        set(pixel) {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let base = calculateBaseOffset(x, y)

            (pixels[base], pixels[base + 1], pixels[base + 2]) = pixel
        }
    }
}

internal extension ScreenBuffer {
    var pixelData: NSData {
        return NSData(bytes: pixels, length: pixels.count)
    }
}
