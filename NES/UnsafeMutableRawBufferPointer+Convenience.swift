import Foundation

extension UnsafeMutableRawBufferPointer {
    static func from(data: Data) -> UnsafeMutableRawBufferPointer {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: data.count)
        buffer.copyBytes(from: data)

        return buffer
    }

    static func allocate(count: Int, initializeWith value: UInt8) -> UnsafeMutableRawBufferPointer {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: count)

        for i in buffer.startIndex ..< buffer.endIndex {
            buffer[i] = value
        }

        return buffer
    }
}

extension UnsafeMutableRawBufferPointer: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = UInt8

    public init(arrayLiteral elements: UInt8...) {
        self = .allocate(count: elements.count)

        copyBytes(from: elements)
    }
}
