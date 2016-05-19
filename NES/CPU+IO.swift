import Foundation

extension CPU: IO {
    func read(address: Address) -> UInt8 {
        switch address {
        case 0..<0x2000:
            return RAM[Int(address % 0x0800)]
        case 0x2000..<0x4000:
            let wrappedAddress = 0x2000 + address % 8

            return PPU.readRegister(wrappedAddress)
        case 0x4000...0x6000:
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
            let wrappedAddress = 0x2000 + address % 8

            PPU.writeRegister(wrappedAddress, value: value)
        case 0x4014:
            PPU.writeRegister(address, value: value)
        case 0x4000..<0x4014, 0x04015:
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

internal extension Address {
    /// The address of the PPU's PPUCTRL register in the CPU's address space.
    static let PPUCTRLAddress: Address = 0x2000

    /// The address of the PPU's PPUMASK register in the CPU's address space.
    static let PPUMASKAddress: Address = 0x2001

    /// The address of the PPU's PPUSTATUS register in the CPU's address space.
    static let PPUSTATUSAddress: Address = 0x2002

    /// The address of the PPU's OAMADDR register in the CPU's address space.
    static let OAMADDRAddress: Address = 0x2003

    /// The address of the PPU's OAMDATA register in the CPU's address space.
    static let OAMDATAAddress: Address = 0x2004

    /// The address of the PPU's PPUSCROLL register in the CPU's address space.
    static let PPUSCROLLAddress: Address = 0x2005

    /// The address of the PPU's PPUADDR register in the CPU's address space.
    static let PPUADDRAddress: Address = 0x2006

    /// The address of the PPU's PPUDATA register in the CPU's address space.
    static let PPUDATAAddress: Address = 0x2007

    /// The address of the PPU's OAMDMA register in the CPU's address space.
    static let OAMDMAAddress: Address = 0x4014
}

/// Maps CPU memory addresses to PPU registers.
private extension PPU {
    func readRegister(address: Address) -> UInt8 {
        switch address {
        case Address.PPUSTATUSAddress:
            defer { didReadPPUSTATUS() }

            return PPUSTATUS
        case Address.OAMDATAAddress:
            return OAMDATA
        case Address.PPUDATAAddress:
            defer { didReadPPUDATA() }

            return bufferedPPUDATA
        default:
            return register
        }
    }

    func writeRegister(address: Address, value: UInt8) {
        register = value

        switch address {
        case Address.PPUCTRLAddress:
            PPUCTRL = value
        case Address.PPUMASKAddress:
            PPUMASK = value
        case Address.OAMADDRAddress:
            OAMADDR = value
        case Address.OAMDATAAddress:
            defer { didWriteOAMDATA() }

            OAMDATA = value
        case Address.PPUSCROLLAddress:
            defer { didWritePPUSCROLL() }

            PPUSCROLL = value
        case Address.PPUADDRAddress:
            defer { didWritePPUADDR() }

            PPUADDR = value
        case Address.PPUDATAAddress:
            defer { didWritePPUDATA() }

            PPUDATA = value
        case Address.OAMDMAAddress:
            defer { didWriteOAMDMA() }

            OAMDMA = value
        default:
            fatalError("Attempt to write illegal PPU register address \(format(address)).")
        }
    }
}
