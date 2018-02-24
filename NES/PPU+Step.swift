import Foundation

internal extension PPU {
    func step() {
        advanceCycleAndScanLine()

        if renderingEnabled {
            if visibleCycle && visibleLine {
                renderPixel()
            }

            if renderLine && fetchCycle {
                shift()

                switch cycle % 8 {
                case 1:
                    fetchNameTableByte()
                case 3:
                    fetchAttributeTableByte()
                case 5:
                    fetchLowTileByte()
                case 7:
                    fetchHighTileByte()
                case 0:
                    feedShiftRegisters()
                default:
                    break
                }
            }

            if renderLine {
                if fetchCycle && cycle % 8 == 0 {
                    incrementX()
                }

                if cycle == 256 {
                    incrementY()
                }

                if cycle == 257 {
                    copyX()
                }
            }

            if preRenderScanline && cycle >= 280 && cycle <= 304 {
                copyY()
            }
        }

        if cycle == 1 {
            if scanLine == 241 {
                verticalBlankStarted = true

                nmiTriggered = nmiTriggered || (nmiEnabled && verticalBlankStarted)
            }

            if preRenderScanline {
                verticalBlankStarted = false

                spriteOverflow = false
                spriteZeroHit = false
            }
        }
    }
}

internal extension PPU {
    func renderPixel() {
        let (x, y) = (cycle - 1, scanLine)

        let mirrored = mirrorPalette(backgroundPixel)

        let color = palette[mirrored]

        let rgba = RGBA.from(paletteColor: color)

        backBuffer[x, y] = rgba
    }

    var backgroundPixel: UInt8 {
        guard showBackground else { return 0x00 }

        let data = tileData >> ((7 - fineX) * 4)

        return UInt8(truncatingIfNeeded: data & 0x0F)
    }
}

internal extension PPU {
    func advanceCycleAndScanLine() {
        cycle += 1

        if cycle > 340 {
            cycle = 0

            scanLine += 1

            if scanLine > 260 {
                scanLine = -1
                frame += 1
                swap(&frontBuffer, &backBuffer)
            }
        }
    }

    func copyX() {
        vramAddress = (vramAddress & 0xFBE0) | (temporaryVRAMAddress & 0x041F)
    }

    func copyY() {
        vramAddress = (vramAddress & 0x841F) | (temporaryVRAMAddress & 0x7BE0)
    }

    func fetchAttributeTableByte() {
        let attributeTableShift = (coarseY & 0x02) << 1 | (coarseX & 0x02)

        let result = ((read(attributeAddress) >> attributeTableShift) & 0x03)

        lowAttributeTableByte  = result[0] ? 0xFF : 0x00
        highAttributeTableByte = result[1] ? 0xFF : 0x00
    }

    func fetchLowTileByte() {
        let address = backgroundPatternTableAddress
                    | UInt16(nameTableByte) << 4
                    | UInt16(fineY)

        lowTileByte = read(address)
    }

    func fetchHighTileByte() {
        let address = backgroundPatternTableAddress
                    | UInt16(nameTableByte) << 4
                    | UInt16(fineY)

        highTileByte = read(address + 0x08)
    }

    func shift() {
        tileData <<= 4

        let a = (shiftRegisters.highAttribute & 0x80) >> 4
        let b = (shiftRegisters.lowAttribute  & 0x80) >> 5
        let c = (shiftRegisters.highTile      & 0x80) >> 6
        let d = (shiftRegisters.lowTile       & 0x80) >> 7

        tileData |= UInt32(truncatingIfNeeded: a | b | c | d)

        shiftRegisters.highAttribute <<= 1
        shiftRegisters.lowAttribute <<= 1
        shiftRegisters.highTile <<= 1
        shiftRegisters.lowTile <<= 1
    }

    func feedShiftRegisters() {
        shiftRegisters.highAttribute = highAttributeTableByte
        shiftRegisters.lowAttribute = lowAttributeTableByte
        shiftRegisters.highTile = highTileByte
        shiftRegisters.lowTile = lowTileByte
    }

    func fetchNameTableByte() {
        nameTableByte = read(tileAddress)
    }

    func incrementX() {
        if coarseX == 0x1F {
            // If `coarseX` is going to wrap, reset it and toggle the lower
            // (horizontal) nametable instead.
            coarseX = 0x00
            nametable ^= 0x01
        } else {
            coarseX += 1
        }
    }

    func incrementY() {
        if fineY == 0x07 {
            // If `fineY` is going to wrap, reset it and increase `coarseY`
            // instead.
            fineY = 0x00

            if coarseY == 0x1D {
                // If `coarseY` is going to roll beyond the supported range,
                // reset it and toggle the higher (vertical) nametable instead.
                coarseY = 0
                nametable ^= 0x02
            } else if coarseY == 0x1F {
                // If `coarseY` is going to roll over, just reset it without
                // toggling the nametable.
                coarseY = 0
            } else {
                coarseY += 1
            }
        } else {
            fineY += 1
        }
    }
}

/// This extension allows easier access to the various meaningful bit ranges
/// within `VRAMAddress` as well as the addresses based on them.
internal extension PPU {
    /// The higher 3 bits of `coarseX` and `coarseY` represent the address of
    /// the current attribute, relative to the first attribute table entry of
    /// the currently selected `nametable`.
    var attributeAddress: Address {
        let n = UInt16(nametable) << 10
        let y = UInt16(coarseY >> 2) << 3
        let x = UInt16(coarseX >> 2)

        return 0x23C0 | n | x | y
    }

    /// Bits 0 through 4 of `VRAMAddress` represent the coarse X position.
    var coarseX: UInt8 {
        get {
            return UInt8(truncatingIfNeeded: vramAddress & 0x001F)
        }
        set {
            precondition(newValue <= 0x1F)

            vramAddress = (vramAddress & 0xFFE0) | UInt16(newValue)
        }
    }

    /// Bits 5 through 9 of `VRAMAddress` represent the coarse Y position.
    var coarseY: UInt8 {
        get {
            return UInt8(truncatingIfNeeded: (vramAddress & 0x03E0) >> 5)
        }
        set {
            precondition(newValue <= 0x1F)

            vramAddress = (vramAddress & 0xFC1F) | UInt16(newValue) << 5
        }
    }

    /// Bits 12 through 14 `VRAMAddress` represent the fine Y position.
    var fineY: UInt8 {
        get {
            return UInt8(truncatingIfNeeded: (vramAddress & 0x7000) >> 12)
        }
        set {
            precondition(newValue <= 0x07)

            vramAddress = (vramAddress & 0x8FFF) | UInt16(newValue) << 12
        }
    }

    /// Bits 10 & 11 of `VRAMAddress` represent the currently selected
    /// nametable.
    var nametable: UInt8 {
        get {
            return UInt8(truncatingIfNeeded: (vramAddress & 0x0C00) >> 10)
        }
        set {
            precondition(newValue <= 0x03)

            vramAddress = (vramAddress & 0xF3FF) | UInt16(newValue) << 10
        }
    }

    /// Bits 0 through 11 of `VRAMAddress` (i.e. `coarseX`, `coarseY` and
    /// `nametable`) represent the address of the current tile, relative to the
    /// the first name table enty at `0x2000`.
    var tileAddress: Address {
        return 0x2000 | (vramAddress & 0x0FFF)
    }
}

private extension PPU {
    var evenFrame: Bool {
        return frame % 2 == 0
    }

    var fetchCycle: Bool {
        return preFetchCycle || visibleCycle
    }

    var postRenderScanline: Bool {
        return scanLine == 240
    }

    var preFetchCycle: Bool {
        return cycle >= 321 && cycle <= 336
    }

    var preRenderScanline: Bool {
        return scanLine < 0
    }

    var renderLine: Bool {
        return preRenderScanline || visibleLine
    }

    var verticalBlankLine: Bool {
        return scanLine >= 241 && scanLine <= 260
    }

    var verticalScrollReloadCycle: Bool {
        return cycle >= 280 && cycle <= 304
    }

    var visibleCycle: Bool {
        return cycle >= 1 && cycle < 257
    }

    var visibleLine: Bool {
        return scanLine >= 0 && scanLine < 240
    }
}
