import Foundation

internal extension UnsafeMutableRawBufferPointer {
    subscript(index: UInt16) -> UInt8 {
        get {
            return self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }

    subscript(index: UInt8) -> UInt8 {
        get {
            return self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }
}
