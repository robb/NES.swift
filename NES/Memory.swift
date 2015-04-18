import Foundation

public struct Memory {
    private var RAM: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0x00)

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

    public func buggyRead16(address: Address) -> UInt16 {
        let low  = read(address)
        let high = read((address & 0xFF00) | UInt16(UInt8(address & 0xFF) &+ 1))

        return UInt16(high, low)
    }

    public mutating func write(address: Address, _ value: UInt8) {
        switch Int(address) {
        case 0x0000..<0x2000:
            RAM[Int(address % 0x0800)] = value
        case 0x2000..<0x4000:
            // TODO: Implement PPU
            break
        case 0x4000..<0x4016, 0x04017:
            // TODO: Implement APU
            break
        case 0x4016:
            // TODO: Implement Controller
            break
        case 0x6000..<0x10000:
            mapper.write(address, value)
        default:
            fatalError("Illegal memory address")
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
