import Foundation

internal typealias Mapper000 = Mapper002

internal final class Mapper002: IO {
    private var cartridge: Cartridge

    private var PRGBanks: (UInt16, UInt16)

    private let numberOfBanks: UInt16

    init(cartridge: Cartridge) {
        self.cartridge = cartridge

        numberOfBanks = UInt16(cartridge.PRGROM.count / 0x4000)
        PRGBanks = (0, numberOfBanks - 1)
    }

    func read(_ address: Address) -> UInt8 {
        switch Int(address) {
        case 0x0000 ..< 0x2000:
            return cartridge.CHRROM[address]
        case 0x2000 ..< 0x6000:
            fatalError("Attempt to read illegal mapper address \(format(address)).")
        case 0x6000 ..< 0x8000:
            let SRAMAddress = address - 0x6000

            return cartridge.SRAM[SRAMAddress]
        case 0x8000 ..< 0xC000:
            let PRGAddress = PRGBanks.0 * 0x4000 + (address - 0x8000)

            return cartridge.PRGROM[PRGAddress]
        case 0xC000 ..< 0x10000:
            let PRGAddress = PRGBanks.1 * 0x4000 + (address - 0xC000)

            return cartridge.PRGROM[PRGAddress]
        default:
            fatalError("Unhandled mapper address \(format(address)).")
        }
    }

    func write(_ address: Address, _ value: UInt8) {
        switch Int(address) {
        case 0x0000 ..< 0x2000:
            cartridge.CHRROM[address] = value
        case 0x2000 ..< 0x6000:
            fatalError("Unhandled mapper address \(format(address)).")
        case 0x6000 ..< 0x8000:
            let SRAMAddress = address - 0x6000

            cartridge.SRAM[SRAMAddress] = value
        case 0x8000 ..< 0x10000:
            PRGBanks.0 = UInt16(value) % numberOfBanks
        default:
            fatalError("Unhandled mapper address \(format(address)).")
        }
    }
}
