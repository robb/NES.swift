import Foundation

/// The CPU of the NES.
public struct CPU {
    public var cycles: UInt64 = 0

    /// The PC register.
    ///
    /// This register holds the program counter.
    public var PC: UInt16 = 0

    /// The SP register.
    ///
    /// This register holds the stack pointer.
    public var SP: UInt8 = 0xFD

    /// The P register.
    ///
    /// This register holds the processor flags.
    public var P: UInt8 = 0x24

    /// The A register.
    public var A: UInt8 = 0

    /// The X register.
    public var X: UInt8 = 0

    /// The Y register.
    public var Y: UInt8 = 0

    public var memory: Memory = Memory()

    public init() { }
}

/// Convenient access to the processor flags in the `P` register.
public extension CPU {
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

    var carryFlag: Bool {
        get {
            return getFlag(0x01)
        }
        set {
            setFlag(0x01, newValue)
        }
    }

    var zeroFlag: Bool {
        get {
            return getFlag(0x02)
        }
        set {
            setFlag(0x02, newValue)
        }
    }

    var interruptDisable: Bool {
        get {
            return getFlag(0x04)
        }
        set {
            setFlag(0x04, newValue)
        }
    }

    var decimalMode: Bool {
        get {
            return getFlag(0x08)
        }
        set {
            setFlag(0x08, newValue)
        }
    }

    var breakCommand: Bool {
        get {
            return getFlag(0x10)
        }
        set {
            setFlag(0x10, newValue)
        }
    }

    var overflowFlag: Bool {
        get {
            return getFlag(0x40)
        }
        set {
            setFlag(0x40, newValue)
        }
    }

    var negativeFlag: Bool {
        get {
            return getFlag(0x80)
        }
        set {
            setFlag(0x80, newValue)
        }
    }

    /// A convenience method for setting the A register as well as the Zero and
    /// Negative flags.
    internal mutating func updateAZN(value: UInt8) {
        A = value
        zeroFlag = value == 0
        negativeFlag = value & 0x80 != 0
    }
}

public extension CPU {
    public static let StackOffset: UInt16 = 0x0100
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
