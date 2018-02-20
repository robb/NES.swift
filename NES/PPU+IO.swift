import Foundation

internal enum MirroringMode {
    case horizontal
    case vertical
    case firstScreen
    case secondScreen
}

extension PPU: IO {
    @discardableResult
    func read(_ address: Address) -> UInt8 {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            return mapper.read(wrappedAddress)
        case 0x2000 ..< 0x3F00:
            let mirrored = mirrorVRAM(wrappedAddress)

            return vram[mirrored]
        case 0x3F00 ..< 0x4000:
            let mirrored = mirrorPalette(wrappedAddress)

            return palette[mirrored]
        default:
            fatalError("Attempt to read illegal PPU memory address \(format(address)).")
        }
    }

    func write(_ address: Address, _ value: UInt8) {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            mapper.write(wrappedAddress, value)
        case 0x2000 ..< 0x3F00:
            let mirrored = mirrorVRAM(wrappedAddress)

            vram[mirrored] = value
        case 0x3F00 ..< 0x4000:
            let mirrored = mirrorPalette(wrappedAddress)

            palette[mirrored] = value
        default:
            fatalError("Attempt to wirte illegal PPU memory address \(format(address)).")
        }
    }

    private static let mirroringLookupTable: [UInt16] = [
        0, 0, 1, 1, // horizontal
        0, 1, 0, 1, // vertical
        0, 0, 0, 0, // firstScreen
        1, 1, 1, 1  // secondScreen
    ]

    internal func mirrorVRAM(_ address: Address, mirroringMode: MirroringMode = .vertical) -> Address {
        let wrappedAddress = (address - 0x2000) % 0x1000
        let index: UInt16 = wrappedAddress / 0x0400
        let offset: UInt16 = wrappedAddress % 0x0400

        switch mirroringMode {
        case .horizontal:
            return ((index >> 1) & 0x0001) * 0x0400 + offset
        case .vertical:
            return (index & 0x0001) * 0x0400 + offset
        case .firstScreen:
            return offset
        case .secondScreen:
            return 0x0400 + offset
        }
    }

    internal func mirrorPalette(_ address: Address) -> UInt8 {
        return mirrorPalette(UInt8(truncatingIfNeeded: address))
    }

    internal func mirrorPalette(_ offset: UInt8) -> UInt8 {
        let wrappedOffset = offset % 32

        if wrappedOffset % 4 == 0 {
            return 0x00
        }

        return wrappedOffset
    }
}
