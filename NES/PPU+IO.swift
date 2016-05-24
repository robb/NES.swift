import Foundation

extension PPU: IO {
    func read(address: Address) -> UInt8 {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            return mapper.read(wrappedAddress)
        case 0x3F00 ..< 0x4000:
            return palette[wrappedAddress % 32]
        default:
            return VRAM[wrappedAddress % 0x0800]
        }
    }

    func write(address: Address, _ value: UInt8) {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            mapper.write(wrappedAddress, value)
        case 0x3F00 ..< 0x4000:
            palette[wrappedAddress % 32] = value
        default:
            VRAM[wrappedAddress % 0x0800] = value
        }
    }
}
