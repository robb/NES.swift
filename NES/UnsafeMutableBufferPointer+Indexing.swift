import Foundation

internal extension UnsafeMutableBufferPointer {
    subscript(index: UInt16) -> Element {
        get {
            return self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }

    subscript(index: UInt8) -> Element {
        get {
            return self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }
}
