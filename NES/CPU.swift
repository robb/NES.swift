import Foundation

/// The CPU of the NES.
internal struct CPU {
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

    var memory: Memory

    init(memory: Memory) {
        self.memory = memory
    }
}

/// Convenient access to the processor flags in the `P` register.
internal extension CPU {
    private func getFlag(flag: UInt8) -> Bool {
        return P & flag != 0
    }

    private mutating func setFlag(flag: UInt8, _ value: Bool) {
        if value {
            P |= flag
        } else {
            P &= ~flag
        }
    }

    /// Carry.
    ///
    /// If `true`, the last addition or shift resulted in a carry or the last
    /// subtraction resulted in no borrow.
    var C: Bool {
        get {
            return getFlag(0x01)
        }
        set {
            setFlag(0x01, newValue)
        }
    }

    /// Zero.
    ///
    /// If `true`, the last operation resulted in `0`.
    var Z: Bool {
        get {
            return getFlag(0x02)
        }
        set {
            setFlag(0x02, newValue)
        }
    }

    /// Interrupt inhibit.
    ///
    /// If `true`, only non-maskable interrupts can be triggered.
    var I: Bool {
        get {
            return getFlag(0x04)
        }
        set {
            setFlag(0x04, newValue)
        }
    }

    /// Decimal.
    ///
    /// If `true`, `ADC` and `SBC` _should_ use binary-coded decimals. However,
    /// this flag has no effect on the NES and is only present here for sake of
    /// completeness.
    var D: Bool {
        get {
            return getFlag(0x08)
        }
        set {
            setFlag(0x08, newValue)
        }
    }

    /// Break.
    ///
    /// Set by `BRK`.
    var B: Bool {
        get {
            return getFlag(0x10)
        }
        set {
            setFlag(0x10, newValue)
        }
    }

    /// Overflow.
    ///
    /// If `true`, the last `ADC` or `SBC` resulted in signed overflow, or the
    /// 6th bit of the last `BIT` was set.
    var V: Bool {
        get {
            return getFlag(0x40)
        }
        set {
            setFlag(0x40, newValue)
        }
    }

    /// Negative.
    ///
    /// If `true`, the last operation resulted in a negative number.
    var N: Bool {
        get {
            return getFlag(0x80)
        }
        set {
            setFlag(0x80, newValue)
        }
    }

    /// A convenience method for setting the A register as well as the Zero and
    /// Negative flags.
    mutating func updateAZN(value: UInt8) {
        A = value
        Z = value == 0
        N = value & 0x80 != 0
    }

    /// A convenience method for setting the Zero and Negative flags.
    mutating func updateZN(value: UInt8) {
        Z = value == 0
        N = value & 0x80 != 0
    }
}

internal extension CPU {
    static let StackOffset: UInt16 = 0x0100
}

/// Stack access.
internal extension CPU {
    mutating func push(byte: UInt8) {
        memory.write(CPU.StackOffset | UInt16(SP), byte)
        SP = SP &- 1
    }

    mutating func push16(value: UInt16) {
        push(UInt8(value >> 8))
        push(UInt8(value & 0xFF))
    }

    mutating func pop() -> UInt8 {
        SP = SP &+ 1
        return memory.read(CPU.StackOffset | UInt16(SP))
    }

    mutating func pop16() -> UInt16 {
        let low: UInt8 = pop()
        let high: UInt8 = pop()

        return UInt16(high) << 8 | UInt16(low)
    }
}
