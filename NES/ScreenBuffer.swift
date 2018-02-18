import Foundation

internal typealias RGBA = UInt32

internal struct ScreenBuffer {
    fileprivate static let componensPerPixel = 4

    static let height = 240

    static let width = 256

    private(set) var pixels: Data

    init() {
        let count = ScreenBuffer.width * ScreenBuffer.height

        pixels = Data(repeating: 0x00, count: count * ScreenBuffer.componensPerPixel)
    }

    private func calculateOffset(_ x: Int, _ y: Int) -> Int {
        return x + y * ScreenBuffer.width
    }

    subscript(x: Int, y: Int) -> RGBA {
        get {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let offset = calculateOffset(x, y)

            return pixels.withUnsafeBytes {
                return $0.advanced(by: offset).pointee
            }
        }
        set(pixel) {
            precondition(x < ScreenBuffer.width)
            precondition(y < ScreenBuffer.height)

            let offset = calculateOffset(x, y)

            pixels.withUnsafeMutableBytes {
                $0.advanced(by: offset).pointee = pixel
            }
        }
    }
}

