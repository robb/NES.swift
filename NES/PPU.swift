import Foundation

internal final class PPU {
    /// The PPU Control register.
    var PPUCTRL: UInt8 = 0

    /// The PPU Mask register.
    var PPUMASK: UInt8 = 0

    /// The PPU Status register.
    ///
    /// Setting the lower five bit has no effect.
    var PPUSTATUS: UInt8 = 0

    /// The OAM Address Port register.
    var OAMADDR: UInt8 = 0

    /// Holds the last value written to any of the above registers.
    ///
    /// Setting this will also affect the five lowest bits of PPUSTATUS.
    var register: UInt8 = 0 {
        didSet {
            PPUSTATUS = (PPUSTATUS & 0xE0) | (register & 0x1F)
        }
    }

    /// Toggled by writing to PPUSCROLL or PPUADDR, cleared by reading
    /// PPUSTATUS.
    var secondWrite: Bool = false

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

    /// Must be called after the CPU has read PPUSTATUS.
    func didReadPPUSTATUS() {
        VBlankStarted = false
        secondWrite = false
    }
}
