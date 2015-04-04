import Foundation

public struct Memory {
    private var bytes: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0xFF)

    public subscript(address: UInt16) -> UInt8 {
        get {
            return bytes[Int(address)]
        }
        set {
            bytes[Int(address)] = newValue
        }
    }

    public subscript(address: UInt16) -> UInt16 {
        get {
            let low  = bytes[Int(address)]
            let high = bytes[Int(address + 1)]

            return UInt16(high) << 8 | UInt16(low)
        }
        set {
            let low  = UInt8(newValue & 0xFF)
            let high = UInt8(newValue >> 8)

            bytes[Int(address)] = low
            bytes[Int(address + 1)] = high
        }
    }
}
