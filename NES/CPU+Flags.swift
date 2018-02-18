import Foundation

/// Convenient access to the processor flags in the `P` register.
internal extension CPU {
    /// Carry.
    ///
    /// If `true`, the last addition or shift resulted in a carry or the last
    /// subtraction resulted in no borrow.
    var c: Bool {
        get {
            return p[0]
        }
        set {
            p[0] = newValue
        }
    }

    /// Zero.
    ///
    /// If `true`, the last operation resulted in `0`.
    var z: Bool {
        get {
            return p[1]
        }
        set {
            p[1] = newValue
        }
    }

    /// Interrupt inhibit.
    ///
    /// If `true`, only non-maskable interrupts can be triggered.
    var i: Bool {
        get {
            return p[2]
        }
        set {
            p[2] = newValue
        }
    }

    /// Decimal.
    ///
    /// If `true`, `ADC` and `SBC` _should_ use binary-coded decimals. However,
    /// this flag has no effect on the NES and is only present here for sake of
    /// completeness.
    var d: Bool {
        get {
            return p[3]
        }
        set {
            p[3] = newValue
        }
    }

    /// Break.
    ///
    /// Set by `BRK`.
    var b: Bool {
        get {
            return p[5]
        }
        set {
            p[5] = newValue
        }
    }

    /// Overflow.
    ///
    /// If `true`, the last `ADC` or `SBC` resulted in signed overflow, or the
    /// 6th bit of the last `BIT` was set.
    var v: Bool {
        get {
            return p[6]
        }
        set {
            p[6] = newValue
        }
    }

    /// Negative.
    ///
    /// If `true`, the last operation resulted in a negative number.
    var n: Bool {
        get {
            return p[7]
        }
        set {
            p[7] = newValue
        }
    }

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
