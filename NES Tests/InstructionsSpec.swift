@testable import NES

import Nimble
import Quick

class InstructionsSpec: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var cpu: CPU {
            console.cpu
        }

        beforeEach {
            console = .consoleWithDummyMapper()
        }

        describe("ADC") {
            it("should add a value to the A register") {
                cpu.a = 0x12

                cpu.adc(0x13)

                expect(cpu.a).to(equal(0x25))
            }

            it("should set the carry flag to false if no overflow occurred") {
                cpu.a = 0x00

                cpu.adc(0x10)

                expect(cpu.a).to(equal(0x10))
                expect(cpu.c).to(beFalse())
            }

            it("should set the carry flag to true if overflow occurred") {
                cpu.a = 0xF0

                cpu.adc(0x20)

                expect(cpu.a).to(equal(0x10))
                expect(cpu.c).to(beTrue())
            }

            it("should set the overflow flag to false if no two's complement overflow occurred") {
                cpu.a = 0x40

                cpu.adc(0x20)

                expect(cpu.a).to(equal(0x60)) // 96 in Two's complement
                expect(cpu.v).to(beFalse())
            }

            it("should set the overflow flag to true if two's complement overflow occurred") {
                cpu.a = 0x40

                cpu.adc(0x40)

                expect(cpu.a).to(equal(0x80)) // -128 in Two's complement
                expect(cpu.v).to(beTrue())
            }
        }

        describe("AND") {
            it("should perform bitwise AND on A and the contents of a byte of memory") {
                cpu.a = 0xF5

                cpu.and(0x5F)

                expect(cpu.a).to(equal(0x55))
            }
        }

        describe("ASL") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the left") {
                    cpu.a = 0x40

                    cpu.asl()

                    expect(cpu.a).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.a = 0x81

                    cpu.asl()

                    expect(cpu.a).to(equal(0x02))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.a = 0x41

                    cpu.asl()

                    expect(cpu.a).to(equal(0x82))
                    expect(cpu.c).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the left") {
                    cpu.write(0x1234, 0x40)

                    cpu.asl(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.write(0x1234, 0x81)

                    cpu.asl(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x02))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.write(0x1234, 0x41)

                    cpu.asl(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x82))
                    expect(cpu.c).to(beFalse())
                }
            }
        }

        describe("BCC") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the carry flag is set") {
                beforeEach {
                    cpu.c = true

                    cpu.bcc(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }

            describe("if the carry flag is clear") {
                beforeEach {
                    cpu.c = false

                    cpu.bcc(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BCS") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the carry flag is set") {
                beforeEach {
                    cpu.c = true

                    cpu.bcs(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the carry flag is clear") {
                beforeEach {
                    cpu.c = false

                    cpu.bcs(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }
        }

        describe("BEQ") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the zero flag is set") {
                beforeEach {
                    cpu.z = true

                    cpu.beq(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the zero flag is clear") {
                beforeEach {
                    cpu.z = false

                    cpu.beq(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }
        }

        describe("BIT") {
            it("should set the zero flag if A & M is 0") {
                cpu.write(0x1000, 0x0F)
                cpu.a = 0xF0

                cpu.bit(0x1000)

                expect(cpu.z).to(beTrue())
            }

            it("should clear the zero flag if A & M is not 0") {
                cpu.write(0x1000, 0xFF)
                cpu.a = 0xF0

                cpu.bit(0x1000)

                expect(cpu.z).to(beFalse())
            }

            it("should set the overflow bit if bit 6 of M is 1") {
                cpu.write(0x1000, 0x40)
                cpu.a = 0x00

                cpu.bit(0x1000)

                expect(cpu.v).to(beTrue())
            }

            it("should clear the overflow bit if bit 6 of M is 1") {
                cpu.write(0x1000, 0x00)
                cpu.a = 0x00

                cpu.bit(0x1000)

                expect(cpu.v).to(beFalse())
            }

            it("should set the negative bit if bit 7 of M is 1") {
                cpu.write(0x1000, 0x80)
                cpu.a = 0x00

                cpu.bit(0x1000)

                expect(cpu.n).to(beTrue())
            }

            it("should clear the negative bit if bit 7 of M is 0") {
                cpu.write(0x1000, 0x00)
                cpu.a = 0x00

                cpu.bit(0x1000)

                expect(cpu.n).to(beFalse())
            }
        }

        describe("BMI") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the negative flag is set") {
                beforeEach {
                    cpu.n = true

                    cpu.bmi(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the negative flag is clear") {
                beforeEach {
                    cpu.n = false

                    cpu.bmi(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }
        }

        describe("BNE") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the zero flag is set") {
                beforeEach {
                    cpu.z = true

                    cpu.bne(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }

            describe("if the zero flag is clear") {
                beforeEach {
                    cpu.z = false

                    cpu.bne(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BPL") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the negative flag is set") {
                beforeEach {
                    cpu.n = true

                    cpu.bpl(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }

            describe("if the negative flag is clear") {
                beforeEach {
                    cpu.n = false

                    cpu.bpl(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BRK") {
            beforeEach {
                cpu.pc = 0xABBA
                cpu.p = 0x24
                cpu.write16(CPU.irqInterruptVector, 0x1234)

                cpu.brk()
            }

            it("should push the program counter to the stack") {
                let PC = cpu.read16(CPU.stackOffset | UInt16(cpu.sp + 2))

                expect(PC).to(equal(0xABBA))
            }

            it("should push the processor status to the stack") {
                let P = cpu.read(CPU.stackOffset | UInt16(cpu.sp + 1))

                expect(P).to(equal(0x24))
            }

            it("should load the IRQ interrupt vector into the PC register") {
                expect(cpu.pc).to(equal(0x1234))
            }

            it("should set the break flag") {
                expect(cpu.b).to(beTrue())
            }
        }

        describe("BVC") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the overflow flag is set") {
                beforeEach {
                    cpu.v = true

                    cpu.bvc(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }

            describe("if the overflow flag is clear") {
                beforeEach {
                    cpu.v = false

                    cpu.bvc(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BVS") {
            beforeEach {
                cpu.pc = 0x4000
            }

            describe("if the overflow flag is set") {
                beforeEach {
                    cpu.v = true

                    cpu.bvs(UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.pc).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the overflow flag is clear") {
                beforeEach {
                    cpu.v = false

                    cpu.bvs(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.pc).to(equal(0x4000))
                }
            }
        }

        describe("CLC") {
            it("should clear the carry flag") {
                cpu.c = true

                cpu.clc()

                expect(cpu.c).to(beFalse())
            }
        }

        describe("CLD") {
            it("should clear the decimal mode flag") {
                cpu.d = true

                cpu.cld()

                expect(cpu.d).to(beFalse())
            }
        }

        describe("CLI") {
            it("should clear the interrupt disable flag") {
                cpu.i = true

                cpu.cli()

                expect(cpu.i).to(beFalse())
            }
        }

        describe("CLV") {
            it("should clear the overflow flag") {
                cpu.v = true

                cpu.clv()

                expect(cpu.v).to(beFalse())
            }
        }

        describe("CMP") {
            it("should set the carry flag if A is greater than or equal to a value") {
                cpu.a = 0x02

                cpu.cmp(0x01)

                expect(cpu.c).to(beTrue())
            }

            it("should clear the carry flag if A is less than a value") {
                cpu.a = 0x01

                cpu.cmp(0x02)

                expect(cpu.c).to(beFalse())
            }

            it("should set the zero flag if A is equal to a value") {
                cpu.a = 0x01

                cpu.cmp(0x01)

                expect(cpu.z).to(beTrue())
            }

            it("should clear the zero flag if A is not equal to a value") {
                cpu.a = 0x02

                cpu.cmp(0x01)

                expect(cpu.z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of A - a value is 1") {
                cpu.a = 0x81

                cpu.cmp(0x01)

                expect(cpu.n).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of A - a value is 0") {
                cpu.a = 0x81

                cpu.cmp(0x02)

                expect(cpu.n).to(beFalse())
            }
        }

        describe("CPX") {
            it("should set the carry flag if X is greater than or equal to a value") {
                cpu.x = 0x02

                cpu.cpx(0x01)

                expect(cpu.c).to(beTrue())
            }

            it("should clear the carry flag if X is less than a value") {
                cpu.x = 0x01

                cpu.cpx(0x02)

                expect(cpu.c).to(beFalse())
            }

            it("should set the zero flag if X is equal to a value") {
                cpu.x = 0x01

                cpu.cpx(0x01)

                expect(cpu.z).to(beTrue())
            }

            it("should clear the zero flag if X is not equal to a value") {
                cpu.x = 0x02

                cpu.cpx(0x01)

                expect(cpu.z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of X - a value is 1") {
                cpu.x = 0x81

                cpu.cpx(0x01)

                expect(cpu.n).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of X - a value is 0") {
                cpu.x = 0x81

                cpu.cpx(0x02)

                expect(cpu.n).to(beFalse())
            }
        }

        describe("CPY") {
            it("should set the carry flag if Y is greater than or equal to a value") {
                cpu.y = 0x02

                cpu.cpy(0x01)

                expect(cpu.c).to(beTrue())
            }

            it("should clear the carry flag if Y is less than a value") {
                cpu.y = 0x01

                cpu.cpy(0x02)

                expect(cpu.c).to(beFalse())
            }

            it("should set the zero flag if Y is equal to a value") {
                cpu.y = 0x01

                cpu.cpy(0x01)

                expect(cpu.z).to(beTrue())
            }

            it("should clear the zero flag if Y is not equal to a value") {
                cpu.y = 0x02

                cpu.cpy(0x01)

                expect(cpu.z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of Y - a value is 1") {
                cpu.y = 0x81

                cpu.cpy(0x01)

                expect(cpu.n).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of Y - a value is 0") {
                cpu.y = 0x81

                cpu.cpy(0x02)

                expect(cpu.n).to(beFalse())
            }
        }

        describe("DEC") {
            it("should decrease the value of a memory location") {
                cpu.write(0x1234, 0x10)

                cpu.dec(0x1234)

                expect(cpu.read(0x1234)).to(equal(0x0F))
            }
        }

        describe("DEX") {
            it("should decrease the value of the X register") {
                cpu.x = 0x10

                cpu.dex()

                expect(cpu.x).to(equal(0x0F))
            }
        }

        describe("DEY") {
            it("should decrease the value of the X register") {
                cpu.y = 0x10

                cpu.dey()

                expect(cpu.y).to(equal(0x0F))
            }
        }

        describe("EOR") {
            it("should perform bitwise XOR on A and a value") {
                cpu.a = 0xF5

                cpu.eor(0x5F)

                expect(cpu.a).to(equal(0xAA))
            }
        }

        describe("INC") {
            it("should increase the value of a memory location") {
                cpu.write(0x1234, 0x10)

                cpu.inc(0x1234)

                expect(cpu.read(0x1234)).to(equal(0x11))
            }
        }

        describe("INX") {
            it("should increase the value of the X register") {
                cpu.x = 0x10

                cpu.inx()

                expect(cpu.x).to(equal(0x11))
            }
        }

        describe("INY") {
            it("should increase the value of the X register") {
                cpu.y = 0x10

                cpu.iny()

                expect(cpu.y).to(equal(0x11))
            }
        }

        describe("JMP") {
            it("should set the PC register") {
                cpu.pc = 0

                cpu.jmp(0x1234)

                expect(cpu.pc).to(equal(0x1234))
            }
        }

        describe("JSR") {
            beforeEach {
                cpu.pc = 0x6543

                cpu.jsr(0x1234)
            }

            it("should push the current address - 1 to the stack") {
                let address = cpu.read16(CPU.stackOffset | UInt16(cpu.sp + 1))

                expect(address).to(equal(0x6542))
            }

            it("should set the PC register") {
                expect(cpu.pc).to(equal(0x1234))
            }
        }

        describe("LDA") {
            it("should store a value in the A register") {
                cpu.lda(0x5F)

                expect(cpu.a).to(equal(0x5F))
            }
        }

        describe("LDX") {
            it("should store a value in the A register") {
                cpu.ldx(0x5F)

                expect(cpu.x).to(equal(0x5F))
            }
        }

        describe("LDY") {
            it("should store a value in the A register") {
                cpu.ldy(0x5F)

                expect(cpu.y).to(equal(0x5F))
            }
        }

        describe("LSR") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the right") {
                    cpu.a = 0x40

                    cpu.lsr()

                    expect(cpu.a).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.a = 0x81

                    cpu.lsr()

                    expect(cpu.a).to(equal(0x40))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.a = 0x80

                    cpu.lsr()

                    expect(cpu.a).to(equal(0x40))
                    expect(cpu.c).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the right") {
                    cpu.write(0x1234, 0x40)

                    cpu.lsr(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.write(0x1234, 0x81)

                    cpu.lsr(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x40))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.write(0x1234, 0x80)

                    cpu.lsr(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x40))
                    expect(cpu.c).to(beFalse())
                }
            }
        }

        describe("ORA") {
            it("should perform bitwise OR on A and a value") {
                cpu.a = 0x01

                cpu.ora(0xF0)

                expect(cpu.a).to(equal(0xF1))
            }
        }

        describe("PHA") {
            it("should push the A register to the stack") {
                cpu.a = 0x24

                cpu.pha()

                let P = cpu.read(CPU.stackOffset | UInt16(cpu.sp + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("PHP") {
            it("should push the processor status to the stack") {
                cpu.p = 0x34

                cpu.php()

                let P = cpu.read(CPU.stackOffset | UInt16(cpu.sp + 1))

                expect(P).to(equal(0x34))
            }
        }

        describe("PLA") {
            it("should pull the A register from the stack") {
                cpu.write(CPU.stackOffset | UInt16(cpu.sp &+ 1), 0x24)

                cpu.pla()

                expect(cpu.a).to(equal(0x24))
            }
        }

        describe("PLP") {
            it("should pull the processor status from the stack") {
                cpu.write(CPU.stackOffset | UInt16(cpu.sp &+ 1), 0x24)

                cpu.plp()

                expect(cpu.p).to(equal(0x24))
            }
        }

        describe("ROL") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the left") {
                    cpu.c = true
                    cpu.a = 0x40

                    cpu.rol()

                    expect(cpu.a).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.a = 0x81

                    cpu.rol()

                    expect(cpu.a).to(equal(0x02))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if bit 7 was 0") {
                    cpu.a = 0x01

                    cpu.rol()

                    expect(cpu.a).to(equal(0x02))
                    expect(cpu.c).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the left") {
                    cpu.c = true
                    cpu.write(0x1234, 0x40)

                    cpu.rol(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.write(0x1234, 0x81)

                    cpu.rol(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x02))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to true if bit 7 was 0") {
                    cpu.write(0x1234, 0x01)

                    cpu.rol(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x02))
                    expect(cpu.c).to(beFalse())
                }
            }
        }

        describe("ROR") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the right") {
                    cpu.c = true
                    cpu.a = 0x04

                    cpu.ror()

                    expect(cpu.a).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.a = 0x81

                    cpu.ror()

                    expect(cpu.a).to(equal(0x40))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.a = 0x80

                    cpu.ror()

                    expect(cpu.a).to(equal(0x40))
                    expect(cpu.c).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the right") {
                    cpu.c = true
                    cpu.write(0x1234, 0x04)

                    cpu.ror(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.write(0x1234, 0x81)

                    cpu.ror(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x40))
                    expect(cpu.c).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.write(0x1234, 0x80)

                    cpu.ror(0x1234)

                    expect(cpu.read(0x1234)).to(equal(0x40))
                    expect(cpu.c).to(beFalse())
                }
            }
        }

        describe("RTI") {
            beforeEach {
                cpu.pc = 0xABBA
                cpu.p = 0x24
                cpu.write16(CPU.irqInterruptVector, 0x1234)

                cpu.brk()

                cpu.pc = 0x1234
                cpu.p = 0xFF

                cpu.rti()
            }

            it("should pull the program counter from the stack") {
                expect(cpu.pc).to(equal(0xABBA))
            }

            it("should pull the processor status from the stack") {
                expect(cpu.p).to(equal(0x24))
            }
        }

        describe("RTS") {
            it("should pull the program counter from the stack") {
                cpu.write16(CPU.stackOffset | UInt16(cpu.sp - 1), 0x1233)
                cpu.sp = cpu.sp &- 2

                cpu.rts()

                expect(cpu.pc).to(equal(0x1234))
            }
        }

        describe("SBC") {
            beforeEach {
                cpu.c = true
            }

            it("should subtract a value from the A register") {
                cpu.a = 0x50

                cpu.sbc(0xF0)

                expect(cpu.a).to(equal(0x60))
            }

            it("should set the carry flag to false if no overflow occurred") {
                cpu.a = 0x50

                cpu.sbc(0x70)

                expect(cpu.a).to(equal(0xE0))
                expect(cpu.c).to(beFalse())
            }

            it("should set the carry flag to true if overflow occurred") {
                cpu.a = 0x50

                cpu.sbc(0x30)

                expect(cpu.a).to(equal(0x20))
                expect(cpu.c).to(beTrue())
            }

            it("should set the overflow flag to false if no two's complement overflow occurred") {
                cpu.a = 0x50

                cpu.sbc(0xF0)

                expect(cpu.a).to(equal(0x60)) // 96 in Two's complement
                expect(cpu.v).to(beFalse())
            }

            it("should set the overflow flag to true if two's complement overflow occurred") {
                cpu.a = 0x50

                cpu.sbc(0xB0)

                expect(cpu.a).to(equal(0xA0)) // 96 in Two's complement
                expect(cpu.v).to(beTrue())
            }
        }

        describe("SEC") {
            it("should set the carry flag") {
                cpu.sec()

                expect(cpu.c).to(beTrue())
            }
        }

        describe("SED") {
            it("should set the decimal mode flag") {
                cpu.sed()

                expect(cpu.d).to(beTrue())
            }
        }

        describe("SEI") {
            it("should set the interrupt disable flag") {
                cpu.sei()

                expect(cpu.i).to(beTrue())
            }
        }

        describe("STA") {
            it("should store the contents of the A register at a memory location") {
                cpu.a = 0x12

                cpu.sta(0x1234)

                expect(cpu.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STX") {
            it("should store the contents of the X register at a memory location") {
                cpu.x = 0x12

                cpu.stx(0x1234)

                expect(cpu.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STY") {
            it("should store the contents of the Y register at a memory location") {
                cpu.y = 0x12

                cpu.sty(0x1234)

                expect(cpu.read(0x1234)).to(equal(0x12))
            }
        }

        describe("TAX") {
            it("should store the contents of the accumulator into the X register") {
                cpu.a = 0x12

                cpu.tax()

                expect(cpu.x).to(equal(0x12))
            }
        }

        describe("TAY") {
            it("should store the contents of the accumulator into the Y register") {
                cpu.a = 0x12

                cpu.tay()

                expect(cpu.y).to(equal(0x12))
            }
        }

        describe("TSX") {
            it("should store the stack pointer in the X register") {
                cpu.sp = 0x12

                cpu.tsx()

                expect(cpu.x).to(equal(0x12))
            }
        }

        describe("TXA") {
            it("should store the X register in the Accumulator") {
                cpu.x = 0x12

                cpu.txa()

                expect(cpu.a).to(equal(0x12))
            }
        }

        describe("TXS") {
            it("should set the Stack Pointer to the current value of the X register") {
                cpu.x = 0x12

                cpu.txs()

                expect(cpu.sp).to(equal(0x12))
            }
        }

        describe("TYA") {
            it("should store the X register in the Accumulator") {
                cpu.y = 0x12

                cpu.tya()

                expect(cpu.a).to(equal(0x12))
            }
        }
    }
}
