import Foundation

internal final class PPU {
    /// The PPU Control register.
    var PPUCTRL: UInt8 = 0

    /// The console this CPU is owned by.
    unowned let console: Console

    /// The CPU.
    var CPU: IO! {
        return console.CPU
    }

    /// The mapper the PPU reads from.
    var mapper: IO! {
        return console.mapper
    }

    /// The VRAM the PPU reads from.
    var VRAM: Array<UInt8>

    init(console: Console, VRAM: Array<UInt8> = Array(count: 0x800, repeatedValue: 0x00)) {
        self.console = console
        self.VRAM = VRAM
    }
}
