import Foundation

/// The CPU of the NES.
internal final class CPU {
    /// The number of cycles the CPU has run for.
    var cycles: Int = 0

    /// The PC register.
    ///
    /// This register holds the program counter.
    var pc: UInt16 = 0

    /// The SP register.
    ///
    /// This register holds the stack pointer.
    var sp: UInt8 = 0xFD

    /// The P register.
    ///
    /// This register holds the processor flags.
    var p: UInt8 = 0x24

    /// The A register.
    var a: UInt8 = 0

    /// The X register.
    var x: UInt8 = 0

    /// The Y register.
    var y: UInt8 = 0

    /// The interrupt that will be evaluated on the next step.
    var interrupt: Interrupt = .none

    /// The number of cycles the CPU should be stalling.
    var stallCycles: Int = 0

    /// The mapper the CPU reads from.
    let mapper: Mapper

    /// The PPU.
    var ppu: PPU!

    /// The RAM the CPU reads from.
    var ram: UnsafeMutableBufferPointer<UInt8>

    var controller1: Controller = Controller()

    var controller2: Controller = Controller()

    init(mapper: Mapper, ram data: Data = Data(repeating: 0x00, count: 0x800)) {
        self.mapper = mapper
        self.ram = .from(source: data)
    }

    deinit {
        ram.deallocate()
    }
}
