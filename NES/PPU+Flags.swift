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
