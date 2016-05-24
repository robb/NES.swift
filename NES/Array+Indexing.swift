import Foundation

internal extension Array {
    subscript(index: UInt16) -> Element {
        get {
            return self[Int(index)]
        }
        set {
            self[Int(index)] = newValue
        }
    }

    subscript(index: UInt8) -> Element {
        get {
            return self[Int(index)]
        }
        set {
            self[Int(index)] = newValue
        }
    }
}
