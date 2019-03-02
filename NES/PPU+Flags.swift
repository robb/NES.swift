import Foundation

/// Convenient access to the flags in the PPUCTRL register.
internal extension PPU {
    var nametableOffset: Address {
        return 0x2000 + UInt16(ppuctrl & 0x03) * 0x0400
    }

    var vramAddressIncrement: UInt16 {
        return ppuctrl[bit: 2] ? 32 : 1
    }

    var spritePatternTableAddress: UInt16 {
        return ppuctrl[bit: 3] ? 0x1000 : 0x0000
    }

    var backgroundPatternTableAddress: UInt16 {
        return ppuctrl[bit: 4] ? 0x1000 : 0x0000
    }

    var useLargeSprites: Bool {
        return ppuctrl[bit: 5]
    }

    var extPinsEnabled: Bool {
        return ppuctrl[bit: 6]
    }

    var nmiEnabled: Bool {
        get {
            return ppuctrl[bit: 7]
        }
        set(flag) {
            ppuctrl[bit: 7] = flag
        }
    }
}

/// Convenient access to the flags in the PPUMASK register.
internal extension PPU {
    var grayscale: Bool {
        return ppumask[bit: 0]
    }

    var showLeftBackground: Bool {
        return ppumask[bit: 1]
    }

    var showLeftSprites: Bool {
        return ppumask[bit: 2]
    }

    var showBackground: Bool {
        return ppumask[bit: 3]
    }

    var showSprites: Bool {
        return ppumask[bit: 4]
    }

    var emphasizeRed: Bool {
        return ppumask[bit: 5]
    }

    var emphasizeGreen: Bool {
        return ppumask[bit: 6]
    }

    var emphasizeBlue: Bool {
        return ppumask[bit: 7]
    }

    var renderingEnabled: Bool {
        return ppumask[bit: 3] || ppumask[bit: 4]
    }
}

/// Convenient access to the flags in the PPUSTATUS register.
internal extension PPU {
    var spriteOverflow: Bool {
        get {
            return ppustatus[bit: 5]
        }
        set {
            ppustatus[bit: 5] = newValue
        }
    }

    var spriteZeroHit: Bool {
        get {
            return ppustatus[bit: 6]
        }
        set {
            ppustatus[bit: 6] = newValue
        }
    }

    var verticalBlankStarted: Bool {
        get {
            return ppustatus[bit: 7]
        }
        set {
            ppustatus[bit: 7] = newValue
        }
    }
}
