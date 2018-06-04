import Foundation

extension UnsafeMutableRawBufferPointer {
    static func from(data: Data) -> UnsafeMutableRawBufferPointer {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: data.count, alignment: 0)
        buffer.copyBytes(from: data)

        return buffer
    }

    static func allocate(count: Int, initializeWith value: UInt8) -> UnsafeMutableRawBufferPointer {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: count, alignment: 0)

        for i in buffer.startIndex ..< buffer.endIndex {
            buffer[i] = value
        }

        return buffer
    }
}

extension UnsafeMutableRawBufferPointer: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = UInt8

    public init(arrayLiteral elements: UInt8...) {
        self = .allocate(byteCount: elements.count, alignment: 0)

        copyBytes(from: elements)
    }
}
