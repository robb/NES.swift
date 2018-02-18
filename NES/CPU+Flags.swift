import Foundation

/// Convenient access to the processor flags in the `P` register.
internal extension CPU {
    /// Carry.
    ///
    /// If `true`, the last addition or shift resulted in a carry or the last
    /// subtraction resulted in no borrow.
    var C: Bool {
        get {
            return P[0]
        }
        set {
            P[0] = newValue
        }
    }

    /// Zero.
    ///
    /// If `true`, the last operation resulted in `0`.
    var Z: Bool {
        get {
            return P[1]
        }
        set {
            P[1] = newValue
        }
    }

    /// Interrupt inhibit.
    ///
    /// If `true`, only non-maskable interrupts can be triggered.
    var I: Bool {
        get {
            return P[2]
        }
        set {
            P[2] = newValue
        }
    }

    /// Decimal.
    ///
    /// If `true`, `ADC` and `SBC` _should_ use binary-coded decimals. However,
    /// this flag has no effect on the NES and is only present here for sake of
    /// completeness.
    var D: Bool {
        get {
            return P[3]
        }
        set {
            P[3] = newValue
        }
    }

    /// Break.
    ///
    /// Set by `BRK`.
    var B: Bool {
        get {
            return P[5]
        }
        set {
            P[5] = newValue
        }
    }

    /// Overflow.
    ///
    /// If `true`, the last `ADC` or `SBC` resulted in signed overflow, or the
    /// 6th bit of the last `BIT` was set.
    var V: Bool {
        get {
            return P[6]
        }
        set {
            P[6] = newValue
        }
    }

    /// Negative.
    ///
    /// If `true`, the last operation resulted in a negative number.
    var N: Bool {
        get {
            return P[7]
        }
        set {
            P[7] = newValue
        }
    }

    /// A convenience method for setting the A register as well as the Zero and
    /// Negative flags.
    func updateAZN(_ value: UInt8) {
        A = value
        Z = value == 0
        N = value & 0x80 != 0
    }

    /// A convenience method for setting the Zero and Negative flags.
    func updateZN(_ value: UInt8) {
        Z = value == 0
        N = value & 0x80 != 0
    }
}
