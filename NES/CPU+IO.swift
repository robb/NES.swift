import Foundation

extension CPU {
    @discardableResult
    @inlinable
    func read(_ address: Address) -> UInt8 {
        switch address {
        case 0x0000 ..< 0x2000:
            return ram[address % 0x0800]
        case 0x2000 ..< 0x4000:
            let wrappedAddress = 0x2000 &+ address % 8

            return ppu.readRegister(wrappedAddress)
        case 0x4000 ..< 0x4016:
            return 0x00
        case 0x4016:
            return controller1.read()
        case 0x4017:
            return controller2.read()
        case 0x4018 ... 0x6000:
            return 0x00
        default:
            return mapper.read(address)
        }
    }

    @inline(__always)
    func read16(_ address: Address) -> UInt16 {
        let low  = read(address)
        let high = read(address + 1)

        return UInt16(high: high, low: low)
    }

    @inline(__always)
    func buggyRead16(_ address: Address) -> UInt16 {
        let low  = read(address)
        let high = read((address & 0xFF00) | UInt16(UInt8(address & 0xFF) &+ 1))

        return UInt16(high: high, low: low)
    }

    @inlinable
    func write(_ address: Address, _ value: UInt8) {
        switch address {
        case 0x0000 ..< 0x2000:
            ram[address % 0x0800] = value
        case 0x2000 ..< 0x4000:
            let wrappedAddress = 0x2000 &+ address % 8

            ppu.writeRegister(wrappedAddress, value: value)
        case 0x4014:
            ppu.writeRegister(address, value: value)
        case 0x4000 ..< 0x4014, 0x04015:
            // TODO: Implement APU
            break
        case 0x4016:
            return controller1.write(value: value)
        case 0x4017:
            return controller2.write(value: value)
        case 0x6000 ... 0xFFFF:
            mapper.write(address, value)
        default:
            fatalError("Attempt to write illegal memory address \(format(address)).")
        }
    }

    @inline(__always)
    func write16(_ address: Address, _ value: UInt16) {
        let low  = UInt8(value & 0xFF)
        let high = UInt8(value >> 8)

        write(address, low)
        write(address + 1, high)
    }
}

internal extension CPU {
    func advanceProgramCounter() -> UInt8 {
        defer { pc = pc &+ 1 }

        return read(pc)
    }

    func advanceProgramCounter() -> UInt16 {
        defer { pc = pc &+ 2 }

        return read16(pc)
    }
}

/// Stack access.
internal extension CPU {
    static let stackOffset: Address = 0x0100

    func push(_ byte: UInt8) {
        write(CPU.stackOffset | UInt16(sp), byte)
        sp = sp &- 1
    }

    func push16(_ value: UInt16) {
        push(UInt8(value >> 8))
        push(UInt8(value & 0xFF))
    }

    func pop() -> UInt8 {
        sp = sp &+ 1
        return read(CPU.stackOffset | UInt16(sp))
    }

    func pop16() -> UInt16 {
        let low: UInt8 = pop()
        let high: UInt8 = pop()

        return UInt16(high) << 8 | UInt16(low)
    }
}

internal extension Address {
    /// The address of the PPU's PPUCTRL register in the CPU's address space.
    static let ppuctrlAddress: Address = 0x2000

    /// The address of the PPU's PPUMASK register in the CPU's address space.
    static let ppumaskAddress: Address = 0x2001

    /// The address of the PPU's PPUSTATUS register in the CPU's address space.
    static let ppustatusAddress: Address = 0x2002

    /// The address of the PPU's OAMADDR register in the CPU's address space.
    static let oamaddrAddress: Address = 0x2003

    /// The address of the PPU's OAMDATA register in the CPU's address space.
    static let oamdataAddress: Address = 0x2004

    /// The address of the PPU's PPUSCROLL register in the CPU's address space.
    static let ppuscrollAddress: Address = 0x2005

    /// The address of the PPU's PPUADDR register in the CPU's address space.
    static let ppuaddrAddress: Address = 0x2006

    /// The address of the PPU's PPUDATA register in the CPU's address space.
    static let ppudataAddress: Address = 0x2007

    /// The address of the PPU's OAMDMA register in the CPU's address space.
    static let oamdmaAddress: Address = 0x4014
}

/// Maps CPU memory addresses to PPU registers.
private extension PPU {
    func readRegister(_ address: Address) -> UInt8 {
        switch address {
        case Address.ppustatusAddress:
            defer { didReadPPUSTATUS() }

            return ppustatus
        case Address.oamdataAddress:
            return oamdata
        case Address.ppudataAddress:
            defer { didReadPPUDATA() }

            return bufferedPPUDATA
        default:
            return register
        }
    }

    func writeRegister(_ address: Address, value: UInt8) {
        register = value

        switch address {
        case Address.ppuctrlAddress:
            defer { didWritePPUCTRL() }

            ppuctrl = value
        case Address.ppumaskAddress:
            ppumask = value
        case Address.oamaddrAddress:
            oamaddr = value
        case Address.oamdataAddress:
            defer { didWriteOAMDATA() }

            oamdata = value
        case Address.ppuscrollAddress:
            defer { didWritePPUSCROLL() }

            ppuscroll = value
        case Address.ppuaddrAddress:
            defer { didWritePPUADDR() }

            ppuaddr = value
        case Address.ppudataAddress:
            defer { didWritePPUDATA() }

            ppudata = value
        case Address.oamdmaAddress:
            defer { didWriteOAMDMA() }

            oamdma = value
        default:
            fatalError("Attempt to write illegal PPU register address \(format(address)).")
        }
    }
}

private extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self.init(UInt16(high) << 8 | UInt16(low))
    }
}
