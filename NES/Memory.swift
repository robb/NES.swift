import Foundation

public struct Memory {
    private var bytes: Array<UInt8> = Array(count: 0x2000, repeatedValue: 0)

    subscript(address: UInt16) -> UInt8 {
        get {
            return bytes[Int(address)]
        }
        set {
            bytes[Int(address)] = newValue
        }
    }
}
