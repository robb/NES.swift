import Foundation

/// The CPU of the NES.
internal final class CPU {
    /// The number of cycles the CPU has run for.
    var cycles: UInt64 = 0

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

    /// The mapper the CPU reads from.
    var mapper: IO

    /// The RAM the CPU reads from.
    var RAM: Array<UInt8>

    init(mapper: IO, RAM: Array<UInt8> = Array(count: 0x800, repeatedValue: 0x00)) {
        self.mapper = mapper
        self.RAM = RAM
    }
}
