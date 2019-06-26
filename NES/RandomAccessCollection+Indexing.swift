import Foundation

internal extension RandomAccessCollection where Index == Int, Self: MutableCollection {
    subscript(index: UInt16) -> Element {
        get {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }

    subscript(index: UInt8) -> Element {
        get {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))]
        }
        set {
            self[Int(bitPattern: UInt(truncatingIfNeeded: index))] = newValue
        }
    }
}
