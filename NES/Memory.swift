import Foundation

public struct Memory {
    private var RAM: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0xFF)

    private var mapper: Mapper

    public func read(address: Address) -> UInt8 {
        switch address {
        case 0...0x2000:
            return RAM[Int(address % 0x0800)]
        case 0x2001...0x6000:
            return 0x00
        default:
            return mapper.read(address)
        }
    }

    public func read16(address: Address) -> UInt16 {
        let low  = read(address)
        let high = read(address + 1)

        return UInt16(high, low)
    }

    public mutating func write(address: Address, _ value: UInt8) {
        switch address {
        case 0...0x2000:
            RAM[Int(address % 0x0800)] = value
        default:
            mapper.write(address, value)
        }
    }

    public mutating func write16(address: Address, _ value: UInt16) {
        let low  = UInt8(value & 0xFF)
        let high = UInt8(value >> 8)

        write(address, low)
        write(address + 1, high)
    }

    public init(mapper: Mapper) {
        self.mapper = mapper
    }
}
