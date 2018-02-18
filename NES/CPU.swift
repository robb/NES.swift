import Foundation

/// The CPU of the NES.
internal final class CPU {
    /// The number of cycles the CPU has run for.
    var cycles: Int = 0

    /// The PC register.
    ///
    /// This register holds the program counter.
    var PC: UInt16 = 0

    /// The SP register.
    ///
    /// This register holds the stack pointer.
    var SP: UInt8 = 0xFD

    /// The P register.
    ///
    /// This register holds the processor flags.
    var P: UInt8 = 0x24

    /// The A register.
    var A: UInt8 = 0

    /// The X register.
    var X: UInt8 = 0

    /// The Y register.
    var Y: UInt8 = 0

    /// The interrupt that will be evaluated on the next step.
    var interrupt: Interrupt = .None

    /// The number of cycles the CPU should be stalling.
    var stallCycles: Int = 0

    /// The console this CPU is owned by.
    unowned let console: Console

    /// The mapper the CPU reads from.
    var mapper: IO! {
        return console.mapper
    }

    /// The PPU.
    var PPU: NES.PPU! {
        return console.PPU
    }

    /// The RAM the CPU reads from.
    var RAM: Array<UInt8>

    init(console: Console, RAM: Array<UInt8> = Array(repeating: 0x00, count: 0x800)) {
        self.console = console
        self.RAM = RAM
    }
}
