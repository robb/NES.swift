import Foundation

extension PPU: IO {
    func read(address: Address) -> UInt8 {
        return VRAM[Int(address % 0x0800)]
    }

    func write(address: Address, _ value: UInt8) {
        VRAM[Int(address % 0x0800)] = value
    }
}
