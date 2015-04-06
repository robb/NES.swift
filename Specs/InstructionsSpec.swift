import NES

import Nimble
import Quick

class InstructionsSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!

        beforeEach {
            cpu = CPU()
        }

        describe("ADC") {
            it("should add a value to the A register") {
                cpu.A = 0x12

                cpu = ADC(cpu, 0x13)

                expect(cpu.A).to(equal(0x25))
            }

            it("should set the carry flag to false if no overflow occurred") {
                cpu.A = 0x00

                cpu = ADC(cpu, 0x10)

                expect(cpu.A).to(equal(0x10))
                expect(cpu.carryFlag).to(beFalse())
            }

            it("should set the carry flag to true if overflow occurred") {
                cpu.A = 0xF0

                cpu = ADC(cpu, 0x20)

                expect(cpu.A).to(equal(0x10))
                expect(cpu.carryFlag).to(beTrue())
            }

            it("should set the overflow flag to false if no two's complement overflow occurred") {
                cpu.A = 0x40

                cpu = ADC(cpu, 0x20)

                expect(cpu.A).to(equal(0x60)) // 96 in Two's complement
                expect(cpu.overflowFlag).to(beFalse())
            }

            it("should set the overflow flag to true if two's complement overflow occurred") {
                cpu.A = 0x40

                cpu = ADC(cpu, 0x40)

                expect(cpu.A).to(equal(0x80)) // -128 in Two's complement
                expect(cpu.overflowFlag).to(beTrue())
            }
        }

        describe("AND") {
            it("should perform bitwise AND on A and the contents of a byte of memory") {
                cpu.A = 0xF5

                cpu = AND(cpu, 0x5F)

                expect(cpu.A).to(equal(0x55))
            }
        }

        describe("ASL") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the left") {
                    cpu.A = 0x40

                    cpu = ASL(cpu)

                    expect(cpu.A).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.A = 0x81

                    cpu = ASL(cpu)

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.A = 0x41

                    cpu = ASL(cpu)

                    expect(cpu.A).to(equal(0x82))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the left") {
                    cpu.memory.write(0x1234, 0x40)

                    cpu = ASL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu = ASL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.memory.write(0x1234, 0x41)

                    cpu = ASL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x82))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }
        }

        describe("BCC") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the carry flag is set") {
                beforeEach {
                    cpu.carryFlag = true

                    cpu = BCC(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the carry flag is clear") {
                beforeEach {
                    cpu.carryFlag = false

                    cpu = BCC(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BCS") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the carry flag is set") {
                beforeEach {
                    cpu.carryFlag = true

                    cpu = BCS(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the carry flag is clear") {
                beforeEach {
                    cpu.carryFlag = false

                    cpu = BCS(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("BEQ") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the zero flag is set") {
                beforeEach {
                    cpu.zeroFlag = true

                    cpu = BEQ(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the zero flag is clear") {
                beforeEach {
                    cpu.zeroFlag = false

                    cpu = BEQ(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("BMI") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the negative flag is set") {
                beforeEach {
                    cpu.negativeFlag = true

                    cpu = BMI(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the negative flag is clear") {
                beforeEach {
                    cpu.negativeFlag = false

                    cpu = BMI(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("BNE") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the zero flag is set") {
                beforeEach {
                    cpu.zeroFlag = true

                    cpu = BNE(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the zero flag is clear") {
                beforeEach {
                    cpu.zeroFlag = false

                    cpu = BNE(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BPL") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the negative flag is set") {
                beforeEach {
                    cpu.negativeFlag = true

                    cpu = BPL(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the negative flag is clear") {
                beforeEach {
                    cpu.negativeFlag = false

                    cpu = BPL(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BRK") {
            beforeEach {
                cpu.PC = 0xABBA
                cpu.P = 0x24
                cpu.memory.write16(0xFFFE, 0x1234)

                cpu = BRK(cpu)
            }

            it("should push the program counter to the stack") {
                let PC = cpu.memory.read16(CPU.StackOffset | UInt16(cpu.SP + 2))

                expect(PC).to(equal(0xABBA))
            }

            it("should push the processor status to the stack") {
                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }

            it("should load the IRQ interrupt vector into the PC register") {
                expect(cpu.PC).to(equal(0x1234))
            }

            it("should set the break flag") {
                expect(cpu.breakCommand).to(beTrue())
            }
        }

        describe("BVC") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the overflow flag is set") {
                beforeEach {
                    cpu.overflowFlag = true

                    cpu = BVC(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the overflow flag is clear") {
                beforeEach {
                    cpu.overflowFlag = false

                    cpu = BVC(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }
        }

        describe("BVS") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the overflow flag is set") {
                beforeEach {
                    cpu.overflowFlag = true

                    cpu = BVS(cpu, UInt8(bitPattern: -32))
                }

                it("should branch") {
                    expect(cpu.PC).to(equal(0x3FE0))
                }

                it("consume additional cycles") {
                    expect(cpu.cycles).to(equal(2))
                }
            }

            describe("if the overflow flag is clear") {
                beforeEach {
                    cpu.overflowFlag = false

                    cpu = BVS(cpu, UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("DEC") {
            it("should increase the value of a memory location") {
                cpu.memory.write(0x1234, 0x10)

                cpu = DEC(cpu, 0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x0F))
            }
        }

        describe("EOR") {
            it("should perform bitwise XOR on A and a value") {
                cpu.A = 0xF5

                cpu = EOR(cpu, 0x5F)

                expect(cpu.A).to(equal(0xAA))
            }
        }

        describe("INC") {
            it("should increase the value of a memory location") {
                cpu.memory.write(0x1234, 0x10)

                cpu = INC(cpu, 0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x11))
            }
        }

        describe("LDA") {
            it("should store a value in the A register") {
                cpu = LDA(cpu, 0x5F)

                expect(cpu.A).to(equal(0x5F))
            }
        }

        describe("LSR") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the right") {
                    cpu.A = 0x40

                    cpu = LSR(cpu)

                    expect(cpu.A).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.A = 0x81

                    cpu = LSR(cpu)

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.A = 0x80

                    cpu = LSR(cpu)

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the right") {
                    cpu.memory.write(0x1234, 0x40)

                    cpu = LSR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu = LSR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.memory.write(0x1234, 0x80)

                    cpu = LSR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }
        }

        describe("ORA") {
            it("should perform bitwise OR on A and a value") {
                cpu.A = 0x01

                cpu = ORA(cpu, 0xF0)

                expect(cpu.A).to(equal(0xF1))
            }
        }

        describe("PHA") {
            it("should push the A register to the stack") {
                cpu.A = 0x24

                cpu = PHA(cpu)

                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("PHP") {
            it("should push the processor status to the stack") {
                cpu.P = 0x24

                cpu = PHP(cpu)

                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("PLA") {
            it("should pull the A register from the stack") {
                cpu.memory.write(CPU.StackOffset | UInt16(cpu.SP &+ 1), 0x24)

                cpu = PLA(cpu)

                expect(cpu.A).to(equal(0x24))
            }
        }

        describe("PLP") {
            it("should pull the processor status from the stack") {
                cpu.memory.write(CPU.StackOffset | UInt16(cpu.SP &+ 1), 0x24)

                cpu = PLP(cpu)

                expect(cpu.P).to(equal(0x24))
            }
        }

        describe("ROL") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the left") {
                    cpu.carryFlag = true
                    cpu.A = 0x40

                    cpu = ROL(cpu)

                    expect(cpu.A).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.A = 0x81

                    cpu = ROL(cpu)

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if bit 7 was 0") {
                    cpu.A = 0x01

                    cpu = ROL(cpu)

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the left") {
                    cpu.carryFlag = true
                    cpu.memory.write(0x1234, 0x40)

                    cpu = ROL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu = ROL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to true if bit 7 was 0") {
                    cpu.memory.write(0x1234, 0x01)

                    cpu = ROL(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }
        }

        describe("ROR") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the right") {
                    cpu.carryFlag = true
                    cpu.A = 0x04

                    cpu = ROR(cpu)

                    expect(cpu.A).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.A = 0x81

                    cpu = ROR(cpu)

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.A = 0x80

                    cpu = ROR(cpu)

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the right") {
                    cpu.carryFlag = true
                    cpu.memory.write(0x1234, 0x04)

                    cpu = ROR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu = ROR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.carryFlag).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.memory.write(0x1234, 0x80)

                    cpu = ROR(cpu, 0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.carryFlag).to(beFalse())
                }
            }
        }

        describe("SEI") {
            it("should set the interrupt disable flag") {
                cpu = SEI(cpu)

                expect(cpu.interruptDisable).to(beTrue())
            }
        }

        describe("STA") {
            it("should store the contents of the A register at a memory location") {
                cpu.A = 0x12

                cpu = STA(cpu, 0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STX") {
            it("should store the contents of the X register at a memory location") {
                cpu.X = 0x12

                cpu = STX(cpu, 0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STY") {
            it("should store the contents of the Y register at a memory location") {
                cpu.Y = 0x12

                cpu = STY(cpu, 0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("TAX") {
            it("should store the contents of the accumulator into the X register") {
                cpu.A = 0x12

                cpu = TAX(cpu)

                expect(cpu.X).to(equal(0x12))
            }
        }

        describe("TAY") {
            it("should store the contents of the accumulator into the Y register") {
                cpu.A = 0x12

                cpu = TAY(cpu)

                expect(cpu.Y).to(equal(0x12))
            }
        }
    }
}
