import Foundation

/// Classes conforming to this protocol can perform IO.
internal protocol IO: class {
    func read(address: Address) -> UInt8

    func write(address: Address, _ value: UInt8)   
}

extension IO {
    func read16(address: Address) -> UInt16 {
        let low  = read(address)
        let high = read(address + 1)

        return UInt16(high, low)
    }

    func buggyRead16(address: Address) -> UInt16 {
        let low  = read(address)
        let high = read((address & 0xFF00) | UInt16(UInt8(address & 0xFF) &+ 1))

        return UInt16(high, low)
    }

    func write16(address: Address, _ value: UInt16) {
        let low  = UInt8(value & 0xFF)
        let high = UInt8(value >> 8)

        write(address, low)
        write(address + 1, high)
    }
}
