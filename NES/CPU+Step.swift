import Foundation

internal extension CPU {
    private func performInterrupt(_ address: Address) {
        push16(pc)
        php()
        pc = read16(address)
        i = true
        cycles = cycles &+ 7
    }

    func step() {
        guard stallCycles == 0 else {
            cycles = cycles &+ 1
            stallCycles = stallCycles &- 1
            return
        }

        switch interrupt {
        case .none:
            break
        case .irq:
            performInterrupt(CPU.irqInterruptVector)
        case .nmi:
            performInterrupt(CPU.nmiInterruptVector)
        }

        interrupt = .none

        let opcode: UInt8 = advanceProgramCounter()

        cycles = cycles &+ cyclesSpent(opcode)

        switch opcode {
        case 0x00: brk()
        case 0x01: ora(indexedIndirect())
        case 0x03: slo(indexedIndirect())
        case 0x04: dop(zeroPage())
        case 0x05: ora(zeroPage())
        case 0x06: asl(zeroPage())
        case 0x07: slo(zeroPage())
        case 0x08: php()
        case 0x09: ora(immediate())
        case 0x0A: asl()
        case 0x0C: top(absolute())
        case 0x0D: ora(absolute())
        case 0x0E: asl(absolute())
        case 0x0F: slo(absolute())
        case 0x10: bpl(relative())
        case 0x11: ora(indirectIndexed(true))
        case 0x13: slo(indirectIndexed(false))
        case 0x14: dop(zeroPageX())
        case 0x15: ora(zeroPageX())
        case 0x16: asl(zeroPageX())
        case 0x17: slo(zeroPageX())
        case 0x18: clc()
        case 0x19: ora(absoluteY(true))
        case 0x1A: nop()
        case 0x1B: slo(absoluteY(false))
        case 0x1C: top(absoluteX(true))
        case 0x1D: ora(absoluteX(true))
        case 0x1E: asl(absoluteX(false))
        case 0x1F: slo(absoluteX(false))
        case 0x20: jsr(absolute())
        case 0x21: and(indexedIndirect())
        case 0x23: rla(indexedIndirect())
        case 0x24: bit(zeroPage())
        case 0x25: and(zeroPage())
        case 0x26: rol(zeroPage())
        case 0x27: rla(zeroPage())
        case 0x28: plp()
        case 0x29: and(immediate())
        case 0x2A: rol()
        case 0x2C: bit(absolute())
        case 0x2D: and(absolute())
        case 0x2E: rol(absolute())
        case 0x2F: rla(absolute())
        case 0x30: bmi(relative())
        case 0x31: and(indirectIndexed(true))
        case 0x33: rla(indirectIndexed(false))
        case 0x34: dop(zeroPageX())
        case 0x35: and(zeroPageX())
        case 0x36: rol(zeroPageX())
        case 0x37: rla(zeroPageX())
        case 0x38: sec()
        case 0x39: and(absoluteY(true))
        case 0x3A: nop()
        case 0x3B: rla(absoluteY(false))
        case 0x3C: top(absoluteX(true))
        case 0x3D: and(absoluteX(true))
        case 0x3E: rol(absoluteX(false))
        case 0x3F: rla(absoluteX(false))
        case 0x40: rti()
        case 0x41: eor(indexedIndirect())
        case 0x43: sre(indexedIndirect())
        case 0x44: dop(zeroPage())
        case 0x45: eor(zeroPage())
        case 0x46: lsr(zeroPage())
        case 0x47: sre(zeroPage())
        case 0x48: pha()
        case 0x49: eor(immediate())
        case 0x4A: lsr()
        case 0x4C: jmp(absolute())
        case 0x4D: eor(absolute())
        case 0x4E: lsr(absolute())
        case 0x4F: sre(absolute())
        case 0x50: bvc(relative())
        case 0x51: eor(indirectIndexed(true))
        case 0x53: sre(indirectIndexed(false))
        case 0x54: dop(zeroPageX())
        case 0x55: eor(zeroPageX())
        case 0x56: lsr(zeroPageX())
        case 0x57: sre(zeroPageX())
        case 0x58: cli()
        case 0x59: eor(absoluteY(true))
        case 0x5A: nop()
        case 0x5B: sre(absoluteY(false))
        case 0x5C: top(absoluteX(true))
        case 0x5D: eor(absoluteX(true))
        case 0x5E: lsr(absoluteX(false))
        case 0x5F: sre(absoluteX(false))
        case 0x60: rts()
        case 0x61: adc(indexedIndirect())
        case 0x63: rra(indexedIndirect())
        case 0x64: dop(zeroPage())
        case 0x65: adc(zeroPage())
        case 0x66: ror(zeroPage())
        case 0x67: rra(zeroPage())
        case 0x68: pla()
        case 0x69: adc(immediate())
        case 0x6A: ror()
        case 0x6C: jmp(indirect())
        case 0x6D: adc(absolute())
        case 0x6E: ror(absolute())
        case 0x6F: rra(absolute())
        case 0x70: bvs(relative())
        case 0x71: adc(indirectIndexed(true))
        case 0x73: rra(indirectIndexed(false))
        case 0x74: dop(zeroPageX())
        case 0x75: adc(zeroPageX())
        case 0x76: ror(zeroPageX())
        case 0x77: rra(zeroPageX())
        case 0x78: sei()
        case 0x79: adc(absoluteY(true))
        case 0x7A: nop()
        case 0x7B: rra(absoluteY(false))
        case 0x7C: top(absoluteX(true))
        case 0x7D: adc(absoluteX(true))
        case 0x7E: ror(absoluteX(false))
        case 0x7F: rra(absoluteX(false))
        case 0x80: dop(immediate())
        case 0x81: sta(indexedIndirect())
        case 0x82: dop(immediate())
        case 0x83: sax(indexedIndirect())
        case 0x84: sty(zeroPage())
        case 0x85: sta(zeroPage())
        case 0x86: stx(zeroPage())
        case 0x87: sax(zeroPage())
        case 0x88: dey()
        case 0x89: dop(immediate())
        case 0x8A: txa()
        case 0x8C: sty(absolute())
        case 0x8D: sta(absolute())
        case 0x8E: stx(absolute())
        case 0x8F: sax(absolute())
        case 0x90: bcc(relative())
        case 0x91: sta(indirectIndexed(true))
        case 0x94: sty(zeroPageX())
        case 0x95: sta(zeroPageX())
        case 0x96: stx(zeroPageY())
        case 0x97: sax(zeroPageY())
        case 0x98: tya()
        case 0x99: sta(absoluteY(false))
        case 0x9A: txs()
        case 0x9D: sta(absoluteX(false))
        case 0xA0: ldy(immediate())
        case 0xA1: lda(indexedIndirect())
        case 0xA2: ldx(immediate())
        case 0xA3: lax(indexedIndirect())
        case 0xA4: ldy(zeroPage())
        case 0xA5: lda(zeroPage())
        case 0xA6: ldx(zeroPage())
        case 0xA7: lax(zeroPage())
        case 0xA8: tay()
        case 0xA9: lda(immediate())
        case 0xAA: tax()
        case 0xAC: ldy(absolute())
        case 0xAD: lda(absolute())
        case 0xAE: ldx(absolute())
        case 0xAF: lax(absolute())
        case 0xB0: bcs(relative())
        case 0xB1: lda(indirectIndexed(true))
        case 0xB3: lax(indirectIndexed(true))
        case 0xB4: ldy(zeroPageX())
        case 0xB5: lda(zeroPageX())
        case 0xB6: ldx(zeroPageY())
        case 0xB7: lax(zeroPageY())
        case 0xB8: clv()
        case 0xB9: lda(absoluteY(true))
        case 0xBA: tsx()
        case 0xBC: ldy(absoluteX(true))
        case 0xBD: lda(absoluteX(true))
        case 0xBE: ldx(absoluteY(true))
        case 0xBF: lax(absoluteY(true))
        case 0xC0: cpy(immediate())
        case 0xC1: cmp(indexedIndirect())
        case 0xC2: dop(immediate())
        case 0xC3: dcp(indexedIndirect())
        case 0xC4: cpy(zeroPage())
        case 0xC5: cmp(zeroPage())
        case 0xC6: dec(zeroPage())
        case 0xC7: dcp(zeroPage())
        case 0xC8: iny()
        case 0xC9: cmp(immediate())
        case 0xCA: dex()
        case 0xCC: cpy(absolute())
        case 0xCD: cmp(absolute())
        case 0xCE: dec(absolute())
        case 0xCF: dcp(absolute())
        case 0xD0: bne(relative())
        case 0xD1: cmp(indirectIndexed(true))
        case 0xD3: dcp(indirectIndexed(false))
        case 0xD4: dop(zeroPageX())
        case 0xD5: cmp(zeroPageX())
        case 0xD6: dec(zeroPageX())
        case 0xD7: dcp(zeroPageX())
        case 0xD8: cld()
        case 0xD9: cmp(absoluteY(true))
        case 0xDA: nop()
        case 0xDB: dcp(absoluteY(false))
        case 0xDC: top(absoluteX(true))
        case 0xDD: cmp(absoluteX(true))
        case 0xDE: dec(absoluteX(false))
        case 0xDF: dcp(absoluteX(false))
        case 0xE0: cpx(immediate())
        case 0xE1: sbc(indexedIndirect())
        case 0xE2: dop(immediate())
        case 0xE3: isc(indexedIndirect())
        case 0xE4: cpx(zeroPage())
        case 0xE5: sbc(zeroPage())
        case 0xE6: inc(zeroPage())
        case 0xE7: isc(zeroPage())
        case 0xE8: inx()
        case 0xE9: sbc(immediate())
        case 0xEA: nop()
        case 0xEB: sbc(immediate())
        case 0xEC: cpx(absolute())
        case 0xED: sbc(absolute())
        case 0xEE: inc(absolute())
        case 0xEF: isc(absolute())
        case 0xF0: beq(relative())
        case 0xF1: sbc(indirectIndexed(true))
        case 0xF3: isc(indirectIndexed(false))
        case 0xF4: dop(zeroPageX())
        case 0xF5: sbc(zeroPageX())
        case 0xF6: inc(zeroPageX())
        case 0xF7: isc(zeroPageX())
        case 0xF8: sed()
        case 0xF9: sbc(absoluteY(true))
        case 0xFA: nop()
        case 0xFB: isc(absoluteY(false))
        case 0xFC: top(absoluteX(true))
        case 0xFD: sbc(absoluteX(true))
        case 0xFE: inc(absoluteX(false))
        case 0xFF: isc(absoluteX(false))

        default:
            fatalError("Attempt to execute illegal opcode \(format(opcode)).")
        }
    }

    func cyclesSpent(_ opcode: UInt8) -> Int {
        switch opcode {
        case 0x09, 0x0A, 0x10, 0x18, 0x1A, 0x29, 0x2A, 0x30, 0x38, 0x3A, 0x49,
             0x4A, 0x50, 0x58, 0x5A, 0x69, 0x6A, 0x70, 0x78, 0x7A, 0x80, 0x82,
             0x88, 0x89, 0x8A, 0x90, 0x98, 0x9A, 0xA0, 0xA2, 0xA8, 0xA9, 0xAA,
             0xB0, 0xB8, 0xBA, 0xC0, 0xC2, 0xC8, 0xC9, 0xCA, 0xD0, 0xD8, 0xDA,
             0xE0, 0xE2, 0xE8, 0xE9, 0xEA, 0xEB, 0xF0, 0xF8, 0xFA:
            return 2

        case 0x04, 0x05, 0x08, 0x24, 0x25, 0x44, 0x45, 0x48, 0x4C, 0x64, 0x65,
             0x84, 0x85, 0x86, 0x87, 0xA4, 0xA5, 0xA6, 0xA7, 0xC4, 0xC5, 0xE4,
             0xE5:
            return 3

        case 0x0C, 0x0D, 0x14, 0x15, 0x19, 0x1C, 0x1D, 0x28, 0x2C, 0x2D, 0x34,
             0x35, 0x39, 0x3C, 0x3D, 0x4D, 0x54, 0x55, 0x59, 0x5C, 0x5D, 0x68,
             0x6D, 0x74, 0x75, 0x79, 0x7C, 0x7D, 0x8C, 0x8D, 0x8E, 0x8F, 0x94,
             0x95, 0x96, 0x97, 0xAC, 0xAD, 0xAE, 0xAF, 0xB4, 0xB5, 0xB6, 0xB7,
             0xB9, 0xBC, 0xBD, 0xBE, 0xBF, 0xCC, 0xCD, 0xD4, 0xD5, 0xD9, 0xDC,
             0xDD, 0xEC, 0xED, 0xF4, 0xF5, 0xF9, 0xFC, 0xFD:
            return 4

        case 0x06, 0x07, 0x11, 0x26, 0x27, 0x31, 0x46, 0x47, 0x51, 0x66, 0x67,
             0x6C, 0x71, 0x99, 0x9D, 0xB1, 0xB3, 0xC6, 0xC7, 0xD1, 0xE6, 0xE7,
             0xF1:
            return 5

        case 0x01, 0x0E, 0x0F, 0x16, 0x17, 0x20, 0x21, 0x2E, 0x2F, 0x36, 0x37,
             0x40, 0x41, 0x4E, 0x4F, 0x56, 0x57, 0x60, 0x61, 0x6E, 0x6F, 0x76,
             0x77, 0x81, 0x83, 0x91, 0xA1, 0xA3, 0xC1, 0xCE, 0xCF, 0xD6, 0xD7,
             0xE1, 0xEE, 0xEF, 0xF6, 0xF7:
            return 6

        case 0x00, 0x1B, 0x1E, 0x1F, 0x3B, 0x3E, 0x3F, 0x5B, 0x5E, 0x5F, 0x7B,
             0x7E, 0x7F, 0xDB, 0xDE, 0xDF, 0xFB, 0xFE, 0xFF:
            return 7

        case 0x03, 0x13, 0x23, 0x33, 0x43, 0x53, 0x63, 0x73, 0xC3, 0xD3, 0xE3,
             0xF3:
            return 8

        default:
            return 0
        }
    }
}
