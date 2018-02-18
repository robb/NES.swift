import Foundation

internal extension CPU {
    private func perform(_ addressingMode: () -> Void, _ instruction: () -> Void) {
        instruction()
    }

    private func perform(_ addressingMode: () -> Address, _ instruction: (Address) -> Void) {
        instruction(addressingMode())
    }

    private func perform(_ addressingMode: () -> UInt8, _ instruction: (UInt8) -> Void) {
        instruction(addressingMode())
    }

    private func perform(_ addressingMode: (Bool) -> Address, _ instruction: (Address) -> Void, incursPageBoundaryCost: Bool = false) {
        instruction(addressingMode(incursPageBoundaryCost))
    }

    private func perform(_ addressingMode: (Bool) -> UInt8, _ instruction: (UInt8) -> Void, incursPageBoundaryCost: Bool = false) {
        instruction(addressingMode(incursPageBoundaryCost))
    }

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
        case 0x00: perform(implied,         brk)
        case 0x01: perform(indexedIndirect, ora)
        case 0x03: perform(indexedIndirect, slo)
        case 0x04: perform(zeroPage,        dop)
        case 0x05: perform(zeroPage,        ora)
        case 0x06: perform(zeroPage,        asl)
        case 0x07: perform(zeroPage,        slo)
        case 0x08: perform(implied,         php)
        case 0x09: perform(immediate,       ora)
        case 0x0A: perform(accumulator,     asl)
        case 0x0C: perform(absolute,        top)
        case 0x0D: perform(absolute,        ora)
        case 0x0E: perform(absolute,        asl)
        case 0x0F: perform(absolute,        slo)
        case 0x10: perform(relative,        bpl)
        case 0x11: perform(indirectIndexed, ora, incursPageBoundaryCost: true)
        case 0x13: perform(indirectIndexed, slo)
        case 0x14: perform(zeroPageX,       dop)
        case 0x15: perform(zeroPageX,       ora)
        case 0x16: perform(zeroPageX,       asl)
        case 0x17: perform(zeroPageX,       slo)
        case 0x18: perform(implied,         clc)
        case 0x19: perform(absoluteY,       ora, incursPageBoundaryCost: true)
        case 0x1A: perform(implied,         nop)
        case 0x1B: perform(absoluteY,       slo)
        case 0x1C: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0x1D: perform(absoluteX,       ora, incursPageBoundaryCost: true)
        case 0x1E: perform(absoluteX,       asl)
        case 0x1F: perform(absoluteX,       slo)
        case 0x20: perform(absolute,        jsr)
        case 0x21: perform(indexedIndirect, and)
        case 0x23: perform(indexedIndirect, rla)
        case 0x24: perform(zeroPage,        bit)
        case 0x25: perform(zeroPage,        and)
        case 0x26: perform(zeroPage,        rol)
        case 0x27: perform(zeroPage,        rla)
        case 0x28: perform(implied,         plp)
        case 0x29: perform(immediate,       and)
        case 0x2A: perform(accumulator,     rol)
        case 0x2C: perform(absolute,        bit)
        case 0x2D: perform(absolute,        and)
        case 0x2E: perform(absolute,        rol)
        case 0x2F: perform(absolute,        rla)
        case 0x30: perform(relative,        bmi)
        case 0x31: perform(indirectIndexed, and, incursPageBoundaryCost: true)
        case 0x33: perform(indirectIndexed, rla)
        case 0x34: perform(zeroPageX,       dop)
        case 0x35: perform(zeroPageX,       and)
        case 0x36: perform(zeroPageX,       rol)
        case 0x37: perform(zeroPageX,       rla)
        case 0x38: perform(implied,         sec)
        case 0x39: perform(absoluteY,       and, incursPageBoundaryCost: true)
        case 0x3A: perform(implied,         nop)
        case 0x3B: perform(absoluteY,       rla)
        case 0x3C: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0x3D: perform(absoluteX,       and, incursPageBoundaryCost: true)
        case 0x3E: perform(absoluteX,       rol)
        case 0x3F: perform(absoluteX,       rla)
        case 0x40: perform(implied,         rti)
        case 0x41: perform(indexedIndirect, eor)
        case 0x43: perform(indexedIndirect, sre)
        case 0x44: perform(zeroPage,        dop)
        case 0x45: perform(zeroPage,        eor)
        case 0x46: perform(zeroPage,        lsr)
        case 0x47: perform(zeroPage,        sre)
        case 0x48: perform(implied,         pha)
        case 0x49: perform(immediate,       eor)
        case 0x4A: perform(accumulator,     lsr)
        case 0x4C: perform(absolute,        jmp)
        case 0x4D: perform(absolute,        eor)
        case 0x4E: perform(absolute,        lsr)
        case 0x4F: perform(absolute,        sre)
        case 0x50: perform(relative,        bvc)
        case 0x51: perform(indirectIndexed, eor, incursPageBoundaryCost: true)
        case 0x53: perform(indirectIndexed, sre)
        case 0x54: perform(zeroPageX,       dop)
        case 0x55: perform(zeroPageX,       eor)
        case 0x56: perform(zeroPageX,       lsr)
        case 0x57: perform(zeroPageX,       sre)
        case 0x58: perform(implied,         cli)
        case 0x59: perform(absoluteY,       eor, incursPageBoundaryCost: true)
        case 0x5A: perform(implied,         nop)
        case 0x5B: perform(absoluteY,       sre)
        case 0x5C: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0x5D: perform(absoluteX,       eor, incursPageBoundaryCost: true)
        case 0x5E: perform(absoluteX,       lsr)
        case 0x5F: perform(absoluteX,       sre)
        case 0x60: perform(implied,         rts)
        case 0x61: perform(indexedIndirect, adc)
        case 0x63: perform(indexedIndirect, rra)
        case 0x64: perform(zeroPage,        dop)
        case 0x65: perform(zeroPage,        adc)
        case 0x66: perform(zeroPage,        ror)
        case 0x67: perform(zeroPage,        rra)
        case 0x68: perform(implied,         pla)
        case 0x69: perform(immediate,       adc)
        case 0x6A: perform(accumulator,     ror)
        case 0x6C: perform(indirect,        jmp)
        case 0x6D: perform(absolute,        adc)
        case 0x6E: perform(absolute,        ror)
        case 0x6F: perform(absolute,        rra)
        case 0x70: perform(relative,        bvs)
        case 0x71: perform(indirectIndexed, adc, incursPageBoundaryCost: true)
        case 0x73: perform(indirectIndexed, rra)
        case 0x74: perform(zeroPageX,       dop)
        case 0x75: perform(zeroPageX,       adc)
        case 0x76: perform(zeroPageX,       ror)
        case 0x77: perform(zeroPageX,       rra)
        case 0x78: perform(implied,         sei)
        case 0x79: perform(absoluteY,       adc, incursPageBoundaryCost: true)
        case 0x7A: perform(implied,         nop)
        case 0x7B: perform(absoluteY,       rra)
        case 0x7C: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0x7D: perform(absoluteX,       adc, incursPageBoundaryCost: true)
        case 0x7E: perform(absoluteX,       ror)
        case 0x7F: perform(absoluteX,       rra)
        case 0x80: perform(immediate,       dop)
        case 0x81: perform(indexedIndirect, sta)
        case 0x82: perform(immediate,       dop)
        case 0x83: perform(indexedIndirect, sax)
        case 0x84: perform(zeroPage,        sty)
        case 0x85: perform(zeroPage,        sta)
        case 0x86: perform(zeroPage,        stx)
        case 0x87: perform(zeroPage,        sax)
        case 0x88: perform(implied,         dey)
        case 0x89: perform(immediate,       dop)
        case 0x8A: perform(implied,         txa)
        case 0x8C: perform(absolute,        sty)
        case 0x8D: perform(absolute,        sta)
        case 0x8E: perform(absolute,        stx)
        case 0x8F: perform(absolute,        sax)
        case 0x90: perform(relative,        bcc)
        case 0x91: perform(indirectIndexed, sta, incursPageBoundaryCost: true)
        case 0x94: perform(zeroPageX,       sty)
        case 0x95: perform(zeroPageX,       sta)
        case 0x96: perform(zeroPageY,       stx)
        case 0x97: perform(zeroPageY,       sax)
        case 0x98: perform(implied,         tya)
        case 0x99: perform(absoluteY,       sta)
        case 0x9A: perform(implied,         txs)
        case 0x9D: perform(absoluteX,       sta)
        case 0xA0: perform(immediate,       ldy)
        case 0xA1: perform(indexedIndirect, lda)
        case 0xA2: perform(immediate,       ldx)
        case 0xA3: perform(indexedIndirect, lax)
        case 0xA4: perform(zeroPage,        ldy)
        case 0xA5: perform(zeroPage,        lda)
        case 0xA6: perform(zeroPage,        ldx)
        case 0xA7: perform(zeroPage,        lax)
        case 0xA8: perform(implied,         tay)
        case 0xA9: perform(immediate,       lda)
        case 0xAA: perform(implied,         tax)
        case 0xAC: perform(absolute,        ldy)
        case 0xAD: perform(absolute,        lda)
        case 0xAE: perform(absolute,        ldx)
        case 0xAF: perform(absolute,        lax)
        case 0xB0: perform(relative,        bcs)
        case 0xB1: perform(indirectIndexed, lda, incursPageBoundaryCost: true)
        case 0xB3: perform(indirectIndexed, lax, incursPageBoundaryCost: true)
        case 0xB4: perform(zeroPageX,       ldy)
        case 0xB5: perform(zeroPageX,       lda)
        case 0xB6: perform(zeroPageY,       ldx)
        case 0xB7: perform(zeroPageY,       lax)
        case 0xB8: perform(implied,         clv)
        case 0xB9: perform(absoluteY,       lda, incursPageBoundaryCost: true)
        case 0xBA: perform(implied,         tsx)
        case 0xBC: perform(absoluteX,       ldy, incursPageBoundaryCost: true)
        case 0xBD: perform(absoluteX,       lda, incursPageBoundaryCost: true)
        case 0xBE: perform(absoluteY,       ldx, incursPageBoundaryCost: true)
        case 0xBF: perform(absoluteY,       lax, incursPageBoundaryCost: true)
        case 0xC0: perform(immediate,       cpy)
        case 0xC1: perform(indexedIndirect, cmp)
        case 0xC2: perform(immediate,       dop)
        case 0xC3: perform(indexedIndirect, dcp)
        case 0xC4: perform(zeroPage,        cpy)
        case 0xC5: perform(zeroPage,        cmp)
        case 0xC6: perform(zeroPage,        dec)
        case 0xC7: perform(zeroPage,        dcp)
        case 0xC8: perform(implied,         iny)
        case 0xC9: perform(immediate,       cmp)
        case 0xCA: perform(implied,         dex)
        case 0xCC: perform(absolute,        cpy)
        case 0xCD: perform(absolute,        cmp)
        case 0xCE: perform(absolute,        dec)
        case 0xCF: perform(absolute,        dcp)
        case 0xD0: perform(relative,        bne)
        case 0xD1: perform(indirectIndexed, cmp, incursPageBoundaryCost: true)
        case 0xD3: perform(indirectIndexed, dcp)
        case 0xD4: perform(zeroPageX,       dop)
        case 0xD5: perform(zeroPageX,       cmp)
        case 0xD6: perform(zeroPageX,       dec)
        case 0xD7: perform(zeroPageX,       dcp)
        case 0xD8: perform(implied,         cld)
        case 0xD9: perform(absoluteY,       cmp, incursPageBoundaryCost: true)
        case 0xDA: perform(implied,         nop)
        case 0xDB: perform(absoluteY,       dcp)
        case 0xDC: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0xDD: perform(absoluteX,       cmp, incursPageBoundaryCost: true)
        case 0xDE: perform(absoluteX,       dec)
        case 0xDF: perform(absoluteX,       dcp)
        case 0xE0: perform(immediate,       cpx)
        case 0xE1: perform(indexedIndirect, sbc)
        case 0xE2: perform(immediate,       dop)
        case 0xE3: perform(indexedIndirect, isc)
        case 0xE4: perform(zeroPage,        cpx)
        case 0xE5: perform(zeroPage,        sbc)
        case 0xE6: perform(zeroPage,        inc)
        case 0xE7: perform(zeroPage,        isc)
        case 0xE8: perform(implied,         inx)
        case 0xE9: perform(immediate,       sbc)
        case 0xEA: perform(implied,         nop)
        case 0xEB: perform(immediate,       sbc)
        case 0xEC: perform(absolute,        cpx)
        case 0xED: perform(absolute,        sbc)
        case 0xEE: perform(absolute,        inc)
        case 0xEF: perform(absolute,        isc)
        case 0xF0: perform(relative,        beq)
        case 0xF1: perform(indirectIndexed, sbc, incursPageBoundaryCost: true)
        case 0xF3: perform(indirectIndexed, isc)
        case 0xF4: perform(zeroPageX,       dop)
        case 0xF5: perform(zeroPageX,       sbc)
        case 0xF6: perform(zeroPageX,       inc)
        case 0xF7: perform(zeroPageX,       isc)
        case 0xF8: perform(implied,         sed)
        case 0xF9: perform(absoluteY,       sbc, incursPageBoundaryCost: true)
        case 0xFA: perform(implied,         nop)
        case 0xFB: perform(absoluteY,       isc)
        case 0xFC: perform(absoluteX,       top, incursPageBoundaryCost: true)
        case 0xFD: perform(absoluteX,       sbc, incursPageBoundaryCost: true)
        case 0xFE: perform(absoluteX,       inc)
        case 0xFF: perform(absoluteX,       isc)

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
