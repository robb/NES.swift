import Foundation

internal typealias Mapper000 = Mapper002

internal final class Mapper002: IO {
    private var cartridge: Cartridge

    private var prgBanks: (UInt16, UInt16)

    private let numberOfBanks: UInt16

    init(cartridge: Cartridge) {
        self.cartridge = cartridge

        numberOfBanks = UInt16(cartridge.prgrom.count / 0x4000)
        prgBanks = (0, numberOfBanks - 1)
    }

    func read(_ address: Address) -> UInt8 {
        switch address {
        case 0x0000 ..< 0x2000:
            return cartridge.chrrom[address]
        case 0x2000 ..< 0x6000:
            fatalError("Attempt to read illegal mapper address \(format(address)).")
        case 0x6000 ..< 0x8000:
            let sramAddress = address - 0x6000

            return cartridge.sram[sramAddress]
        case 0x8000 ..< 0xC000:
            let prgAddress = prgBanks.0 * 0x4000 + (address - 0x8000)

            return cartridge.prgrom[prgAddress]
        case 0xC000 ... 0xFFFF:
            let prgAddress = prgBanks.1 * 0x4000 + (address - 0xC000)

            return cartridge.prgrom[prgAddress]
        default:
            fatalError("Unhandled mapper address \(format(address)).")
        }
    }

    func write(_ address: Address, _ value: UInt8) {
        switch address {
        case 0x0000 ..< 0x2000:
            cartridge.chrrom[address] = value
        case 0x2000 ..< 0x6000:
            fatalError("Unhandled mapper address \(format(address)).")
        case 0x6000 ..< 0x8000:
            let SRAMAddress = address - 0x6000

            cartridge.sram[SRAMAddress] = value
        case 0x8000 ... 0xFFFF:
            prgBanks.0 = UInt16(value) % numberOfBanks
        default:
            fatalError("Unhandled mapper address \(format(address)).")
        }
    }
}
