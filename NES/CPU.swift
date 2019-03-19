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
    var p: UInt8 {
        get {
            var result: UInt8 = 0

            result[bit: 0] = c
            result[bit: 1] = z
            result[bit: 2] = i
            result[bit: 3] = d
            result[bit: 5] = b
            result[bit: 6] = v
            result[bit: 7] = n

            return result
        }
        set {
            c = newValue[bit: 0]
            z = newValue[bit: 1]
            i = newValue[bit: 2]
            d = newValue[bit: 3]
            b = newValue[bit: 5]
            v = newValue[bit: 6]
            n = newValue[bit: 7]
        }
    }

    /// Carry.
    ///
    /// If `true`, the last addition or shift resulted in a carry or the last
    /// subtraction resulted in no borrow.
    var c: Bool = false

    /// Zero.
    ///
    /// If `true`, the last operation resulted in `0`.
    var z: Bool = false

    /// Interrupt inhibit.
    ///
    /// If `true`, only non-maskable interrupts can be triggered.
    var i: Bool = true

    /// Decimal.
    ///
    /// If `true`, `ADC` and `SBC` _should_ use binary-coded decimals. However,
    /// this flag has no effect on the NES and is only present here for sake of
    /// completeness.
    var d: Bool = false

    /// Break.
    ///
    /// Set by `BRK`.
    var b: Bool = false

    /// Overflow.
    ///
    /// If `true`, the last `ADC` or `SBC` resulted in signed overflow, or the
    /// 6th bit of the last `BIT` was set.
    var v: Bool = true

    /// Negative.
    ///
    /// If `true`, the last operation resulted in a negative number.
    var n: Bool = false

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
    var ram: ContiguousArray<UInt8>

    var controller1: Controller = Controller()

    var controller2: Controller = Controller()

    init(mapper: Mapper, ram data: Data = Data(repeating: 0x00, count: 0x800)) {
        self.mapper = mapper
        self.ram = ContiguousArray(data)
    }
}

internal extension CPU {
    /// A convenience method for setting the A register as well as the Zero and
    /// Negative flags.
    func updateAZN(_ value: UInt8) {
        a = value
        z = value == 0
        n = value & 0x80 != 0
    }

    /// A convenience method for setting the Zero and Negative flags.
    func updateZN(_ value: UInt8) {
        z = value == 0
        n = value & 0x80 != 0
    }
}
