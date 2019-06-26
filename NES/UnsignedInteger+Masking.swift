import Foundation

internal extension UnsignedInteger where Self: FixedWidthInteger {
    private func get(nibble: Int) -> UInt8 {
        precondition(0 <= nibble && nibble < Self.bitWidth)

        let offset = Self(truncatingIfNeeded: nibble) &* 4

        let mask = (0x0F as Self) &<< offset

        return UInt8(truncatingIfNeeded: (self & mask) &>> offset)
    }

    private mutating func set(nibble: Int, _ value: UInt8) {
        precondition(0 <= nibble && nibble < Self.bitWidth)

        let offset = Self(truncatingIfNeeded: nibble) &* 4

        let mask = (0x0F as Self) &<< offset

        self &= ~mask
        self |= Self(truncatingIfNeeded: value & 0x0F) &<< offset
    }

    subscript(nibble nibble: Int) -> UInt8 {
        get {
            get(nibble: nibble)
        }
        set {
            set(nibble: nibble, newValue)
        }
    }

    private func get(bit: Int) -> Bool {
        precondition(0 <= bit && bit < Self.bitWidth)

        let mask = Self(1 << bit)

        return (self & mask) != 0
    }

    private mutating func set(bit: Int, _ value: Bool) {
        precondition(0 <= bit && bit < Self.bitWidth)

        let mask = Self(1 << bit)

        if value {
            self |= mask
        } else {
            self &= ~mask
        }
    }

    subscript(bit bit: Int) -> Bool {
        get {
            get(bit: bit)
        }
        set(value) {
            set(bit: bit, value)
        }
    }

}
