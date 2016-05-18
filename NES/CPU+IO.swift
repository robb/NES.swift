import Foundation

extension CPU: IO {
    func read(address: Address) -> UInt8 {
        switch address {
        case 0...0x2000:
            return RAM[Int(address % 0x0800)]
        case 0x2001...0x6000:
            return 0x00
        default:
            return mapper.read(address)
        }
    }

    func write(address: Address, _ value: UInt8) {
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
            fatalError("Attempt to write illegal memory address \(format(address)).")
        }
    }
}

internal extension CPU {
    func advanceProgramCounter() -> UInt8 {
        let result = read(PC)

        PC = PC &+ 1

        return result
    }

    func advanceProgramCounter() -> UInt16 {
        let result = read16(PC)

        PC = PC &+ 2

        return result
    }
}

/// Stack access.
internal extension CPU {
    static let StackOffset: Address = 0x0100

    func push(byte: UInt8) {
        write(CPU.StackOffset | UInt16(SP), byte)
        SP = SP &- 1
    }

    func push16(value: UInt16) {
        push(UInt8(value >> 8))
        push(UInt8(value & 0xFF))
    }

    func pop() -> UInt8 {
        SP = SP &+ 1
        return read(CPU.StackOffset | UInt16(SP))
    }

    func pop16() -> UInt16 {
        let low: UInt8 = pop()
        let high: UInt8 = pop()

        return UInt16(high) << 8 | UInt16(low)
    }
}
