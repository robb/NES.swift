import Foundation

public struct Memory {
    private var bytes: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0xFF)

    public func read(address: Address) -> UInt8 {
        return bytes[Int(address)]
    }

    public func read16(address: Address) -> UInt16 {
        let low  = bytes[Int(address)]
        let high = bytes[Int(address + 1)]

        return UInt16(high, low)
    }

    public mutating func write(address: UInt16, _ value: UInt8) {
        bytes[Int(address)] = value
    }

    public mutating func write16(address: Address, _ value: UInt16) {
        let low  = UInt8(value & 0xFF)
        let high = UInt8(value >> 8)

        bytes[Int(address)] = low
        bytes[Int(address + 1)] = high
    }
}
