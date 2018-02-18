import Foundation

/// Convenient access to the flags in the PPUCTRL register.
internal extension PPU {
    var nametableOffset: Address {
        return 0x2000 + UInt16(ppuctrl & 0x03) * 0x0400
    }

    var vramAddressIncrement: UInt16 {
        return ppuctrl[2] ? 32 : 1
    }

    var spritePatternTableAddress: UInt16 {
        return ppuctrl[3] ? 0x1000 : 0x0000
    }

    var backgroundPatternTableAddress: UInt16 {
        return ppuctrl[4] ? 0x1000 : 0x0000
    }

    var useLargeSprites: Bool {
        return ppuctrl[5]
    }

    var extPinsEnabled: Bool {
        return ppuctrl[6]
    }

    var nmiEnabled: Bool {
        get {
            return ppuctrl[7]
        }
        set(flag) {
            ppuctrl[7] = flag
        }
    }
}

/// Convenient access to the flags in the PPUMASK register.
internal extension PPU {
    var grayscale: Bool {
        return ppumask[0]
    }

    var showLeftBackground: Bool {
        return ppumask[1]
    }

    var showLeftSprites: Bool {
        return ppumask[2]
    }

    var showBackground: Bool {
        return ppumask[3]
    }

    var showSprites: Bool {
        return ppumask[4]
    }

    var emphasizeRed: Bool {
        return ppumask[5]
    }

    var emphasizeGreen: Bool {
        return ppumask[6]
    }

    var emphasizeBlue: Bool {
        return ppumask[7]
    }
}

/// Convenient access to the flags in the PPUSTATUS register.
internal extension PPU {
    var spriteOverflow: Bool {
        get {
            return ppustatus[5]
        }
        set {
            ppustatus[5] = newValue
        }
    }

    var spriteZeroHit: Bool {
        get {
            return ppustatus[6]
        }
        set {
            ppustatus[6] = newValue
        }
    }

    var verticalBlankStarted: Bool {
        get {
            return ppustatus[7]
        }
        set {
            ppustatus[7] = newValue
        }
    }
}
