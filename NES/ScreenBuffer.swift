import Foundation

final internal class ScreenBuffer {
    static let componensPerPixel = 4

    static let height = 240

    static let width = 256

    static let pixelCount = ScreenBuffer.width * ScreenBuffer.height

    let pointer: UnsafeMutablePointer<RGBA>

    private(set) var pixels: UnsafeMutableBufferPointer<RGBA>

    init() {
        pointer = .allocate(capacity: ScreenBuffer.pixelCount)

        pixels = UnsafeMutableBufferPointer(start: pointer, count: ScreenBuffer.pixelCount)
    }

    func deallocate() {
        pointer.deallocate(capacity: ScreenBuffer.pixelCount)
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

