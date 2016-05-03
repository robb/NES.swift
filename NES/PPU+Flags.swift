import Foundation

/// Convenient access to the flags in the PPUCTRL register.
internal extension PPU {
    var nametableOffset: Address {
        return 0x2000 + UInt16(PPUCTRL & 0x03) * 0x0400
    }

    var VRAMAddressIncrement: UInt16 {
        return PPUCTRL[2] ? 32 : 1
    }

    var spritePatternTableAddress: UInt16 {
        return PPUCTRL[3] ? 0x1000 : 0x0000
    }

    var backgroundPatternTableAddress: UInt16 {
        return PPUCTRL[4] ? 0x1000 : 0x0000
    }

    var useLargeSprites: Bool {
        return PPUCTRL[5]
    }

    var EXTPinsEnabled: Bool {
        return PPUCTRL[6]
    }

    var NMIEnabled: Bool {
        get {
            return PPUCTRL[7]
        }
        set(flag) {
            PPUCTRL[7] = flag
        }
    }
}

/// Convenient access to the flags in the PPUMASK register.
internal extension PPU {
    var grayscale: Bool {
        return PPUMASK[0]
    }

    var showLeftBackground: Bool {
        return PPUMASK[1]
    }

    var showLeftSprites: Bool {
        return PPUMASK[2]
    }

    var showBackground: Bool {
        return PPUMASK[3]
    }

    var showSprites: Bool {
        return PPUMASK[4]
    }

    var emphasizeRed: Bool {
        return PPUMASK[5]
    }

    var emphasizeGreen: Bool {
        return PPUMASK[6]
    }

    var emphasizeBlue: Bool {
        return PPUMASK[7]
    }
}

/// Convenient access to the flags in the PPUSTATUS register.
internal extension PPU {
    var spriteOverflow: Bool {
        get {
            return PPUSTATUS[5]
        }
        set {
            PPUSTATUS[5] = newValue
        }
    }

    var spriteZeroHit: Bool {
        get {
            return PPUSTATUS[6]
        }
        set {
            PPUSTATUS[6] = newValue
        }
    }

    var VBlankStarted: Bool {
        get {
            return PPUSTATUS[7]
        }
        set {
            PPUSTATUS[7] = newValue
        }
    }
}
