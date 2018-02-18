import Foundation

internal extension Data {
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
