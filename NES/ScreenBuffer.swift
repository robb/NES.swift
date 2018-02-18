import Foundation

internal typealias RGBA = UInt32

internal struct ScreenBuffer {
    fileprivate static let componensPerPixel = 4

    static let height = 240

    static let width = 256

    fileprivate var pixels: Array<RGBA>

    init() {
        let count = ScreenBuffer.width * ScreenBuffer.height

        pixels = Array<RGBA>(repeating: 0x00000000, count: count)
    }

    private func calculateOffset(_ x: Int, _ y: Int) -> Int {
        return x + y * ScreenBuffer.width
    }

    subscript(x: Int, y: Int) -> RGBA {
        get {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let offset = calculateOffset(x, y)

            return pixels[offset]
        }
        set(pixel) {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let offset = calculateOffset(x, y)

            pixels[offset] = pixel
        }
    }
}

internal extension ScreenBuffer {
    var pixelData: Data {
        return Data(bytes: pixels, count: pixels.count * ScreenBuffer.componensPerPixel)
    }
}
