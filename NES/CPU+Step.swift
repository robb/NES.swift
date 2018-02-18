import Foundation

internal extension CPU {
    private func perform<A>(_ addressingMode: () -> A, _ instruction: (A) -> Void) {
        instruction(addressingMode())
    }

    private func perform<A>(_ addressingMode: (Bool) -> A, _ instruction: (A) -> Void) {
        instruction(addressingMode(false))
    }

    private func perform<A>(_ addressingMode: (Bool) -> A, _ instruction: (A) -> Void, incursPageBoundaryCost: Bool) {
        instruction(addressingMode(incursPageBoundaryCost))
    }

    private func performInterrupt(_ address: Address) {
        push16(PC)
        PHP()
        PC = read16(address)
        I = true
        cycles += 7
    }

    func step() {
        guard stallCycles == 0 else {
            cycles += 1
            stallCycles -= 1
            return
        }

        switch interrupt {
        case .None:
            break
        case .IRQ:
            performInterrupt(CPU.IRQInterruptVector)
        case .NMI:
            performInterrupt(CPU.NMIInterruptVector)
        }

        interrupt = .None

        let opcode: UInt8 = advanceProgramCounter()

        cycles += cyclesSpent(opcode)

        switch opcode {
        case 0x00: perform(implied,         BRK)
        case 0x01: perform(indexedIndirect, ORA)
        case 0x03: perform(indexedIndirect, SLO)
        case 0x04: perform(zeroPage,        DOP)
        case 0x05: perform(zeroPage,        ORA)
        case 0x06: perform(zeroPage,        ASL)
        case 0x07: perform(zeroPage,        SLO)
        case 0x08: perform(implied,         PHP)
        case 0x09: perform(immediate,       ORA)
        case 0x0A: perform(accumulator,     ASL)
        case 0x0C: perform(absolute,        TOP)
        case 0x0D: perform(absolute,        ORA)
        case 0x0E: perform(absolute,        ASL)
        case 0x0F: perform(absolute,        SLO)
        case 0x10: perform(relative,        BPL)
        case 0x11: perform(indirectIndexed, ORA, incursPageBoundaryCost: true)
        case 0x13: perform(indirectIndexed, SLO)
        case 0x14: perform(zeroPageX,       DOP)
        case 0x15: perform(zeroPageX,       ORA)
        case 0x16: perform(zeroPageX,       ASL)
        case 0x17: perform(zeroPageX,       SLO)
        case 0x18: perform(implied,         CLC)
        case 0x19: perform(absoluteY,       ORA, incursPageBoundaryCost: true)
        case 0x1A: perform(implied,         NOP)
        case 0x1B: perform(absoluteY,       SLO)
        case 0x1C: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0x1D: perform(absoluteX,       ORA, incursPageBoundaryCost: true)
        case 0x1E: perform(absoluteX,       ASL)
        case 0x1F: perform(absoluteX,       SLO)
        case 0x20: perform(absolute,        JSR)
        case 0x21: perform(indexedIndirect, AND)
        case 0x23: perform(indexedIndirect, RLA)
        case 0x24: perform(zeroPage,        BIT)
        case 0x25: perform(zeroPage,        AND)
        case 0x26: perform(zeroPage,        ROL)
        case 0x27: perform(zeroPage,        RLA)
        case 0x28: perform(implied,         PLP)
        case 0x29: perform(immediate,       AND)
        case 0x2A: perform(accumulator,     ROL)
        case 0x2C: perform(absolute,        BIT)
        case 0x2D: perform(absolute,        AND)
        case 0x2E: perform(absolute,        ROL)
        case 0x2F: perform(absolute,        RLA)
        case 0x30: perform(relative,        BMI)
        case 0x31: perform(indirectIndexed, AND, incursPageBoundaryCost: true)
        case 0x33: perform(indirectIndexed, RLA)
        case 0x34: perform(zeroPageX,       DOP)
        case 0x35: perform(zeroPageX,       AND)
        case 0x36: perform(zeroPageX,       ROL)
        case 0x37: perform(zeroPageX,       RLA)
        case 0x38: perform(implied,         SEC)
        case 0x39: perform(absoluteY,       AND, incursPageBoundaryCost: true)
        case 0x3A: perform(implied,         NOP)
        case 0x3B: perform(absoluteY,       RLA)
        case 0x3C: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0x3D: perform(absoluteX,       AND, incursPageBoundaryCost: true)
        case 0x3E: perform(absoluteX,       ROL)
        case 0x3F: perform(absoluteX,       RLA)
        case 0x40: perform(implied,         RTI)
        case 0x41: perform(indexedIndirect, EOR)
        case 0x43: perform(indexedIndirect, SRE)
        case 0x44: perform(zeroPage,        DOP)
        case 0x45: perform(zeroPage,        EOR)
        case 0x46: perform(zeroPage,        LSR)
        case 0x47: perform(zeroPage,        SRE)
        case 0x48: perform(implied,         PHA)
        case 0x49: perform(immediate,       EOR)
        case 0x4A: perform(accumulator,     LSR)
        case 0x4C: perform(absolute,        JMP)
        case 0x4D: perform(absolute,        EOR)
        case 0x4E: perform(absolute,        LSR)
        case 0x4F: perform(absolute,        SRE)
        case 0x50: perform(relative,        BVC)
        case 0x51: perform(indirectIndexed, EOR, incursPageBoundaryCost: true)
        case 0x53: perform(indirectIndexed, SRE)
        case 0x54: perform(zeroPageX,       DOP)
        case 0x55: perform(zeroPageX,       EOR)
        case 0x56: perform(zeroPageX,       LSR)
        case 0x57: perform(zeroPageX,       SRE)
        case 0x58: perform(implied,         CLI)
        case 0x59: perform(absoluteY,       EOR, incursPageBoundaryCost: true)
        case 0x5A: perform(implied,         NOP)
        case 0x5B: perform(absoluteY,       SRE)
        case 0x5C: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0x5D: perform(absoluteX,       EOR, incursPageBoundaryCost: true)
        case 0x5E: perform(absoluteX,       LSR)
        case 0x5F: perform(absoluteX,       SRE)
        case 0x60: perform(implied,         RTS)
        case 0x61: perform(indexedIndirect, ADC)
        case 0x63: perform(indexedIndirect, RRA)
        case 0x64: perform(zeroPage,        DOP)
        case 0x65: perform(zeroPage,        ADC)
        case 0x66: perform(zeroPage,        ROR)
        case 0x67: perform(zeroPage,        RRA)
        case 0x68: perform(implied,         PLA)
        case 0x69: perform(immediate,       ADC)
        case 0x6A: perform(accumulator,     ROR)
        case 0x6C: perform(indirect,        JMP)
        case 0x6D: perform(absolute,        ADC)
        case 0x6E: perform(absolute,        ROR)
        case 0x6F: perform(absolute,        RRA)
        case 0x70: perform(relative,        BVS)
        case 0x71: perform(indirectIndexed, ADC, incursPageBoundaryCost: true)
        case 0x73: perform(indirectIndexed, RRA)
        case 0x74: perform(zeroPageX,       DOP)
        case 0x75: perform(zeroPageX,       ADC)
        case 0x76: perform(zeroPageX,       ROR)
        case 0x77: perform(zeroPageX,       RRA)
        case 0x78: perform(implied,         SEI)
        case 0x79: perform(absoluteY,       ADC, incursPageBoundaryCost: true)
        case 0x7A: perform(implied,         NOP)
        case 0x7B: perform(absoluteY,       RRA)
        case 0x7C: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0x7D: perform(absoluteX,       ADC, incursPageBoundaryCost: true)
        case 0x7E: perform(absoluteX,       ROR)
        case 0x7F: perform(absoluteX,       RRA)
        case 0x80: perform(immediate,       DOP)
        case 0x81: perform(indexedIndirect, STA)
        case 0x82: perform(immediate,       DOP)
        case 0x83: perform(indexedIndirect, SAX)
        case 0x84: perform(zeroPage,        STY)
        case 0x85: perform(zeroPage,        STA)
        case 0x86: perform(zeroPage,        STX)
        case 0x87: perform(zeroPage,        SAX)
        case 0x88: perform(implied,         DEY)
        case 0x89: perform(immediate,       DOP)
        case 0x8A: perform(implied,         TXA)
        case 0x8C: perform(absolute,        STY)
        case 0x8D: perform(absolute,        STA)
        case 0x8E: perform(absolute,        STX)
        case 0x8F: perform(absolute,        SAX)
        case 0x90: perform(relative,        BCC)
        case 0x91: perform(indirectIndexed, STA, incursPageBoundaryCost: true)
        case 0x94: perform(zeroPageX,       STY)
        case 0x95: perform(zeroPageX,       STA)
        case 0x96: perform(zeroPageY,       STX)
        case 0x97: perform(zeroPageY,       SAX)
        case 0x98: perform(implied,         TYA)
        case 0x99: perform(absoluteY,       STA)
        case 0x9A: perform(implied,         TXS)
        case 0x9D: perform(absoluteX,       STA)
        case 0xA0: perform(immediate,       LDY)
        case 0xA1: perform(indexedIndirect, LDA)
        case 0xA2: perform(immediate,       LDX)
        case 0xA3: perform(indexedIndirect, LAX)
        case 0xA4: perform(zeroPage,        LDY)
        case 0xA5: perform(zeroPage,        LDA)
        case 0xA6: perform(zeroPage,        LDX)
        case 0xA7: perform(zeroPage,        LAX)
        case 0xA8: perform(implied,         TAY)
        case 0xA9: perform(immediate,       LDA)
        case 0xAA: perform(implied,         TAX)
        case 0xAC: perform(absolute,        LDY)
        case 0xAD: perform(absolute,        LDA)
        case 0xAE: perform(absolute,        LDX)
        case 0xAF: perform(absolute,        LAX)
        case 0xB0: perform(relative,        BCS)
        case 0xB1: perform(indirectIndexed, LDA, incursPageBoundaryCost: true)
        case 0xB3: perform(indirectIndexed, LAX, incursPageBoundaryCost: true)
        case 0xB4: perform(zeroPageX,       LDY)
        case 0xB5: perform(zeroPageX,       LDA)
        case 0xB6: perform(zeroPageY,       LDX)
        case 0xB7: perform(zeroPageY,       LAX)
        case 0xB8: perform(implied,         CLV)
        case 0xB9: perform(absoluteY,       LDA, incursPageBoundaryCost: true)
        case 0xBA: perform(implied,         TSX)
        case 0xBC: perform(absoluteX,       LDY, incursPageBoundaryCost: true)
        case 0xBD: perform(absoluteX,       LDA, incursPageBoundaryCost: true)
        case 0xBE: perform(absoluteY,       LDX, incursPageBoundaryCost: true)
        case 0xBF: perform(absoluteY,       LAX, incursPageBoundaryCost: true)
        case 0xC0: perform(immediate,       CPY)
        case 0xC1: perform(indexedIndirect, CMP)
        case 0xC2: perform(immediate,       DOP)
        case 0xC3: perform(indexedIndirect, DCP)
        case 0xC4: perform(zeroPage,        CPY)
        case 0xC5: perform(zeroPage,        CMP)
        case 0xC6: perform(zeroPage,        DEC)
        case 0xC7: perform(zeroPage,        DCP)
        case 0xC8: perform(implied,         INY)
        case 0xC9: perform(immediate,       CMP)
        case 0xCA: perform(implied,         DEX)
        case 0xCC: perform(absolute,        CPY)
        case 0xCD: perform(absolute,        CMP)
        case 0xCE: perform(absolute,        DEC)
        case 0xCF: perform(absolute,        DCP)
        case 0xD0: perform(relative,        BNE)
        case 0xD1: perform(indirectIndexed, CMP, incursPageBoundaryCost: true)
        case 0xD3: perform(indirectIndexed, DCP)
        case 0xD4: perform(zeroPageX,       DOP)
        case 0xD5: perform(zeroPageX,       CMP)
        case 0xD6: perform(zeroPageX,       DEC)
        case 0xD7: perform(zeroPageX,       DCP)
        case 0xD8: perform(implied,         CLD)
        case 0xD9: perform(absoluteY,       CMP, incursPageBoundaryCost: true)
        case 0xDA: perform(implied,         NOP)
        case 0xDB: perform(absoluteY,       DCP)
        case 0xDC: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0xDD: perform(absoluteX,       CMP, incursPageBoundaryCost: true)
        case 0xDE: perform(absoluteX,       DEC)
        case 0xDF: perform(absoluteX,       DCP)
        case 0xE0: perform(immediate,       CPX)
        case 0xE1: perform(indexedIndirect, SBC)
        case 0xE2: perform(immediate,       DOP)
        case 0xE3: perform(indexedIndirect, ISC)
        case 0xE4: perform(zeroPage,        CPX)
        case 0xE5: perform(zeroPage,        SBC)
        case 0xE6: perform(zeroPage,        INC)
        case 0xE7: perform(zeroPage,        ISC)
        case 0xE8: perform(implied,         INX)
        case 0xE9: perform(immediate,       SBC)
        case 0xEA: perform(implied,         NOP)
        case 0xEB: perform(immediate,       SBC)
        case 0xEC: perform(absolute,        CPX)
        case 0xED: perform(absolute,        SBC)
        case 0xEE: perform(absolute,        INC)
        case 0xEF: perform(absolute,        ISC)
        case 0xF0: perform(relative,        BEQ)
        case 0xF1: perform(indirectIndexed, SBC, incursPageBoundaryCost: true)
        case 0xF3: perform(indirectIndexed, ISC)
        case 0xF4: perform(zeroPageX,       DOP)
        case 0xF5: perform(zeroPageX,       SBC)
        case 0xF6: perform(zeroPageX,       INC)
        case 0xF7: perform(zeroPageX,       ISC)
        case 0xF8: perform(implied,         SED)
        case 0xF9: perform(absoluteY,       SBC, incursPageBoundaryCost: true)
        case 0xFA: perform(implied,         NOP)
        case 0xFB: perform(absoluteY,       ISC)
        case 0xFC: perform(absoluteX,       TOP, incursPageBoundaryCost: true)
        case 0xFD: perform(absoluteX,       SBC, incursPageBoundaryCost: true)
        case 0xFE: perform(absoluteX,       INC)
        case 0xFF: perform(absoluteX,       ISC)

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
