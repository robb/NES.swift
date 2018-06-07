import Foundation

extension UnsafeMutableBufferPointer {
    static func from<C: Collection>(source: C) -> UnsafeMutableBufferPointer<C.Element> {
        let buffer = UnsafeMutableBufferPointer<C.Element>.allocate(capacity: source.count)
        _ = buffer.initialize(from: source)

        return buffer
    }
}

extension UnsafeMutableBufferPointer {
    static func allocate<E>(count: Int, initializeWith value: E) -> UnsafeMutableBufferPointer<E> {
        let buffer = UnsafeMutableBufferPointer<E>.allocate(capacity: count)
        buffer.initialize(repeating: value)

        return buffer
    }
}

extension UnsafeMutableBufferPointer: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self = .allocate(capacity: elements.count)

        _ = initialize(from: elements)
    }
}
