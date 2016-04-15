@testable import NES

import Nimble
import Quick

class InstructionsSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!

        beforeEach {
            cpu = CPU(memory: Memory(mapper: DummyMapper()))
        }

        describe("ADC") {
            it("should add a value to the A register") {
                cpu.A = 0x12

                cpu.ADC(0x13)

                expect(cpu.A).to(equal(0x25))
            }

            it("should set the carry flag to false if no overflow occurred") {
                cpu.A = 0x00

                cpu.ADC(0x10)

                expect(cpu.A).to(equal(0x10))
                expect(cpu.C).to(beFalse())
            }

            it("should set the carry flag to true if overflow occurred") {
                cpu.A = 0xF0

                cpu.ADC(0x20)

                expect(cpu.A).to(equal(0x10))
                expect(cpu.C).to(beTrue())
            }

            it("should set the overflow flag to false if no two's complement overflow occurred") {
                cpu.A = 0x40

                cpu.ADC(0x20)

                expect(cpu.A).to(equal(0x60)) // 96 in Two's complement
                expect(cpu.V).to(beFalse())
            }

            it("should set the overflow flag to true if two's complement overflow occurred") {
                cpu.A = 0x40

                cpu.ADC(0x40)

                expect(cpu.A).to(equal(0x80)) // -128 in Two's complement
                expect(cpu.V).to(beTrue())
            }
        }

        describe("AND") {
            it("should perform bitwise AND on A and the contents of a byte of memory") {
                cpu.A = 0xF5

                cpu.AND(0x5F)

                expect(cpu.A).to(equal(0x55))
            }
        }

        describe("ASL") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the left") {
                    cpu.A = 0x40

                    cpu.ASL()

                    expect(cpu.A).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.A = 0x81

                    cpu.ASL()

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.A = 0x41

                    cpu.ASL()

                    expect(cpu.A).to(equal(0x82))
                    expect(cpu.C).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the left") {
                    cpu.memory.write(0x1234, 0x40)

                    cpu.ASL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x80))
                }

                it("should set the carry flag to true if overflow occurred") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu.ASL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if no overflow occurred") {
                    cpu.memory.write(0x1234, 0x41)

                    cpu.ASL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x82))
                    expect(cpu.C).to(beFalse())
                }
            }
        }

        describe("BCC") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the carry flag is set") {
                beforeEach {
                    cpu.C = true

                    cpu.BCC(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the carry flag is clear") {
                beforeEach {
                    cpu.C = false

                    cpu.BCC(UInt8(bitPattern: -32))
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
                    cpu.C = true

                    cpu.BCS(UInt8(bitPattern: -32))
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
                    cpu.C = false

                    cpu.BCS(UInt8(bitPattern: -32))
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
                    cpu.Z = true

                    cpu.BEQ(UInt8(bitPattern: -32))
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
                    cpu.Z = false

                    cpu.BEQ(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("BIT") {
            it("should set the zero flag if A & M is 0") {
                cpu.memory.write(0x1000, 0x0F)
                cpu.A = 0xF0

                cpu.BIT(0x1000)

                expect(cpu.Z).to(beTrue())
            }

            it("should clear the zero flag if A & M is not 0") {
                cpu.memory.write(0x1000, 0xFF)
                cpu.A = 0xF0

                cpu.BIT(0x1000)

                expect(cpu.Z).to(beFalse())
            }

            it("should set the overflow bit if bit 6 of M is 1") {
                cpu.memory.write(0x1000, 0x40)
                cpu.A = 0x00

                cpu.BIT(0x1000)

                expect(cpu.V).to(beTrue())
            }

            it("should clear the overflow bit if bit 6 of M is 1") {
                cpu.memory.write(0x1000, 0x00)
                cpu.A = 0x00

                cpu.BIT(0x1000)

                expect(cpu.V).to(beFalse())
            }

            it("should set the negative bit if bit 7 of M is 1") {
                cpu.memory.write(0x1000, 0x80)
                cpu.A = 0x00

                cpu.BIT(0x1000)

                expect(cpu.N).to(beTrue())
            }

            it("should clear the negative bit if bit 7 of M is 0") {
                cpu.memory.write(0x1000, 0x00)
                cpu.A = 0x00

                cpu.BIT(0x1000)

                expect(cpu.N).to(beFalse())
            }
        }

        describe("BMI") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the negative flag is set") {
                beforeEach {
                    cpu.N = true

                    cpu.BMI(UInt8(bitPattern: -32))
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
                    cpu.N = false

                    cpu.BMI(UInt8(bitPattern: -32))
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
                    cpu.Z = true

                    cpu.BNE(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the zero flag is clear") {
                beforeEach {
                    cpu.Z = false

                    cpu.BNE(UInt8(bitPattern: -32))
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
                    cpu.N = true

                    cpu.BPL(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the negative flag is clear") {
                beforeEach {
                    cpu.N = false

                    cpu.BPL(UInt8(bitPattern: -32))
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

                cpu.BRK()
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
                expect(cpu.B).to(beTrue())
            }
        }

        describe("BVC") {
            beforeEach {
                cpu.PC = 0x4000
            }

            describe("if the overflow flag is set") {
                beforeEach {
                    cpu.V = true

                    cpu.BVC(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }

            describe("if the overflow flag is clear") {
                beforeEach {
                    cpu.V = false

                    cpu.BVC(UInt8(bitPattern: -32))
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
                    cpu.V = true

                    cpu.BVS(UInt8(bitPattern: -32))
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
                    cpu.V = false

                    cpu.BVS(UInt8(bitPattern: -32))
                }

                it("should not branch") {
                    expect(cpu.PC).to(equal(0x4000))
                }
            }
        }

        describe("CLC") {
            it("should clear the carry flag") {
                cpu.C = true

                cpu.CLC()

                expect(cpu.C).to(beFalse())
            }
        }

        describe("CLD") {
            it("should clear the decimal mode flag") {
                cpu.D = true

                cpu.CLD()

                expect(cpu.D).to(beFalse())
            }
        }

        describe("CLI") {
            it("should clear the interrupt disable flag") {
                cpu.I = true

                cpu.CLI()

                expect(cpu.I).to(beFalse())
            }
        }

        describe("CLV") {
            it("should clear the overflow flag") {
                cpu.V = true

                cpu.CLV()

                expect(cpu.V).to(beFalse())
            }
        }

        describe("CMP") {
            it("should set the carry flag if A is greater than or equal to a value") {
                cpu.A = 0x02

                cpu.CMP(0x01)

                expect(cpu.C).to(beTrue())
            }

            it("should clear the carry flag if A is less than a value") {
                cpu.A = 0x01

                cpu.CMP(0x02)

                expect(cpu.C).to(beFalse())
            }

            it("should set the zero flag if A is equal to a value") {
                cpu.A = 0x01

                cpu.CMP(0x01)

                expect(cpu.Z).to(beTrue())
            }

            it("should clear the zero flag if A is not equal to a value") {
                cpu.A = 0x02

                cpu.CMP(0x01)

                expect(cpu.Z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of A - a value is 1") {
                cpu.A = 0x81

                cpu.CMP(0x01)

                expect(cpu.N).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of A - a value is 0") {
                cpu.A = 0x81

                cpu.CMP(0x02)

                expect(cpu.N).to(beFalse())
            }
        }

        describe("CPX") {
            it("should set the carry flag if X is greater than or equal to a value") {
                cpu.X = 0x02

                cpu.CPX(0x01)

                expect(cpu.C).to(beTrue())
            }

            it("should clear the carry flag if X is less than a value") {
                cpu.X = 0x01

                cpu.CPX(0x02)

                expect(cpu.C).to(beFalse())
            }

            it("should set the zero flag if X is equal to a value") {
                cpu.X = 0x01

                cpu.CPX(0x01)

                expect(cpu.Z).to(beTrue())
            }

            it("should clear the zero flag if X is not equal to a value") {
                cpu.X = 0x02

                cpu.CPX(0x01)

                expect(cpu.Z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of X - a value is 1") {
                cpu.X = 0x81

                cpu.CPX(0x01)

                expect(cpu.N).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of X - a value is 0") {
                cpu.X = 0x81

                cpu.CPX(0x02)

                expect(cpu.N).to(beFalse())
            }
        }

        describe("CPY") {
            it("should set the carry flag if Y is greater than or equal to a value") {
                cpu.Y = 0x02

                cpu.CPY(0x01)

                expect(cpu.C).to(beTrue())
            }

            it("should clear the carry flag if Y is less than a value") {
                cpu.Y = 0x01

                cpu.CPY(0x02)

                expect(cpu.C).to(beFalse())
            }

            it("should set the zero flag if Y is equal to a value") {
                cpu.Y = 0x01

                cpu.CPY(0x01)

                expect(cpu.Z).to(beTrue())
            }

            it("should clear the zero flag if Y is not equal to a value") {
                cpu.Y = 0x02

                cpu.CPY(0x01)

                expect(cpu.Z).to(beFalse())
            }

            it("should set the negative flag if bit 7 of Y - a value is 1") {
                cpu.Y = 0x81

                cpu.CPY(0x01)

                expect(cpu.N).to(beTrue())
            }

            it("should clear the negative flag if bit 7 of Y - a value is 0") {
                cpu.Y = 0x81

                cpu.CPY(0x02)

                expect(cpu.N).to(beFalse())
            }
        }

        describe("DEC") {
            it("should decrease the value of a memory location") {
                cpu.memory.write(0x1234, 0x10)

                cpu.DEC(0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x0F))
            }
        }

        describe("DEX") {
            it("should decrease the value of the X register") {
                cpu.X = 0x10

                cpu.DEX()

                expect(cpu.X).to(equal(0x0F))
            }
        }

        describe("DEY") {
            it("should decrease the value of the X register") {
                cpu.Y = 0x10

                cpu.DEY()

                expect(cpu.Y).to(equal(0x0F))
            }
        }

        describe("EOR") {
            it("should perform bitwise XOR on A and a value") {
                cpu.A = 0xF5

                cpu.EOR(0x5F)

                expect(cpu.A).to(equal(0xAA))
            }
        }

        describe("INC") {
            it("should increase the value of a memory location") {
                cpu.memory.write(0x1234, 0x10)

                cpu.INC(0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x11))
            }
        }

        describe("INX") {
            it("should increase the value of the X register") {
                cpu.X = 0x10

                cpu.INX()

                expect(cpu.X).to(equal(0x11))
            }
        }

        describe("INY") {
            it("should increase the value of the X register") {
                cpu.Y = 0x10

                cpu.INY()

                expect(cpu.Y).to(equal(0x11))
            }
        }

        describe("JMP") {
            it("should set the PC register") {
                cpu.PC = 0

                cpu.JMP(0x1234)

                expect(cpu.PC).to(equal(0x1234))
            }
        }

        describe("JSR") {
            beforeEach {
                cpu.PC = 0x6543

                cpu.JSR(0x1234)
            }

            it("should push the current address - 1 to the stack") {
                let address = cpu.memory.read16(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(address).to(equal(0x6542))
            }

            it("should set the PC register") {
                expect(cpu.PC).to(equal(0x1234))
            }
        }

        describe("LDA") {
            it("should store a value in the A register") {
                cpu.LDA(0x5F)

                expect(cpu.A).to(equal(0x5F))
            }
        }

        describe("LDX") {
            it("should store a value in the A register") {
                cpu.LDX(0x5F)

                expect(cpu.X).to(equal(0x5F))
            }
        }

        describe("LDY") {
            it("should store a value in the A register") {
                cpu.LDY(0x5F)

                expect(cpu.Y).to(equal(0x5F))
            }
        }

        describe("LSR") {
            describe("when called without an address") {
                it("should should shift all bits of the accumulator one bit to the right") {
                    cpu.A = 0x40

                    cpu.LSR()

                    expect(cpu.A).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.A = 0x81

                    cpu.LSR()

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.A = 0x80

                    cpu.LSR()

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.C).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should shift all bits of the memory contents one bit to the right") {
                    cpu.memory.write(0x1234, 0x40)

                    cpu.LSR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x20))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu.LSR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.memory.write(0x1234, 0x80)

                    cpu.LSR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.C).to(beFalse())
                }
            }
        }

        describe("ORA") {
            it("should perform bitwise OR on A and a value") {
                cpu.A = 0x01

                cpu.ORA(0xF0)

                expect(cpu.A).to(equal(0xF1))
            }
        }

        describe("PHA") {
            it("should push the A register to the stack") {
                cpu.A = 0x24

                cpu.PHA()

                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("PHP") {
            it("should push the processor status to the stack") {
                cpu.P = 0x34

                cpu.PHP()

                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x34))
            }
        }

        describe("PLA") {
            it("should pull the A register from the stack") {
                cpu.memory.write(CPU.StackOffset | UInt16(cpu.SP &+ 1), 0x24)

                cpu.PLA()

                expect(cpu.A).to(equal(0x24))
            }
        }

        describe("PLP") {
            it("should pull the processor status from the stack") {
                cpu.memory.write(CPU.StackOffset | UInt16(cpu.SP &+ 1), 0x24)

                cpu.PLP()

                expect(cpu.P).to(equal(0x24))
            }
        }

        describe("ROL") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the left") {
                    cpu.C = true
                    cpu.A = 0x40

                    cpu.ROL()

                    expect(cpu.A).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.A = 0x81

                    cpu.ROL()

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if bit 7 was 0") {
                    cpu.A = 0x01

                    cpu.ROL()

                    expect(cpu.A).to(equal(0x02))
                    expect(cpu.C).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the left") {
                    cpu.C = true
                    cpu.memory.write(0x1234, 0x40)

                    cpu.ROL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x81))
                }

                it("should set the carry flag to true if bit 7 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu.ROL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to true if bit 7 was 0") {
                    cpu.memory.write(0x1234, 0x01)

                    cpu.ROL(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x02))
                    expect(cpu.C).to(beFalse())
                }
            }
        }

        describe("ROR") {
            describe("when called without an address") {
                it("should should rotate all bits of the accumulator one bit to the right") {
                    cpu.C = true
                    cpu.A = 0x04

                    cpu.ROR()

                    expect(cpu.A).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.A = 0x81

                    cpu.ROR()

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.A = 0x80

                    cpu.ROR()

                    expect(cpu.A).to(equal(0x40))
                    expect(cpu.C).to(beFalse())
                }
            }

            describe("when called with an address") {
                it("should should rotate all bits of the memory contents one bit to the right") {
                    cpu.C = true
                    cpu.memory.write(0x1234, 0x04)

                    cpu.ROR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x82))
                }

                it("should set the carry flag to true if bit 0 was 1") {
                    cpu.memory.write(0x1234, 0x81)

                    cpu.ROR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.C).to(beTrue())
                }

                it("should set the carry flag to false if bit 0 was 0") {
                    cpu.memory.write(0x1234, 0x80)

                    cpu.ROR(0x1234)

                    expect(cpu.memory.read(0x1234)).to(equal(0x40))
                    expect(cpu.C).to(beFalse())
                }
            }
        }

        describe("RTI") {
            beforeEach {
                cpu.PC = 0xABBA
                cpu.P = 0x24
                cpu.memory.write16(0xFFFE, 0x1234)

                cpu.BRK()

                cpu.PC = 0x1234
                cpu.P = 0xFF

                cpu.RTI()
            }

            it("should pull the program counter from the stack") {
                expect(cpu.PC).to(equal(0xABBA))
            }

            it("should pull the processor status from the stack") {
                expect(cpu.P).to(equal(0x24))
            }
        }

        describe("RTS") {
            it("should pull the program counter from the stack") {
                cpu.memory.write16(CPU.StackOffset | UInt16(cpu.SP - 1), 0x1233)
                cpu.SP = cpu.SP &- 2

                cpu.RTS()

                expect(cpu.PC).to(equal(0x1234))
            }
        }

        describe("SBC") {
            beforeEach {
                cpu.C = true
            }

            it("should subtract a value from the A register") {
                cpu.A = 0x50

                cpu.SBC(0xF0)

                expect(cpu.A).to(equal(0x60))
            }

            it("should set the carry flag to false if no overflow occurred") {
                cpu.A = 0x50

                cpu.SBC(0x70)

                expect(cpu.A).to(equal(0xE0))
                expect(cpu.C).to(beFalse())
            }

            it("should set the carry flag to true if overflow occurred") {
                cpu.A = 0x50

                cpu.SBC(0x30)

                expect(cpu.A).to(equal(0x20))
                expect(cpu.C).to(beTrue())
            }

            it("should set the overflow flag to false if no two's complement overflow occurred") {
                cpu.A = 0x50

                cpu.SBC(0xF0)

                expect(cpu.A).to(equal(0x60)) // 96 in Two's complement
                expect(cpu.V).to(beFalse())
            }

            it("should set the overflow flag to true if two's complement overflow occurred") {
                cpu.A = 0x50

                cpu.SBC(0xB0)

                expect(cpu.A).to(equal(0xA0)) // 96 in Two's complement
                expect(cpu.V).to(beTrue())
            }
        }

        describe("SEC") {
            it("should set the carry flag") {
                cpu.SEC()

                expect(cpu.C).to(beTrue())
            }
        }

        describe("SED") {
            it("should set the decimal mode flag") {
                cpu.SED()

                expect(cpu.D).to(beTrue())
            }
        }

        describe("SEI") {
            it("should set the interrupt disable flag") {
                cpu.SEI()

                expect(cpu.I).to(beTrue())
            }
        }

        describe("STA") {
            it("should store the contents of the A register at a memory location") {
                cpu.A = 0x12

                cpu.STA(0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STX") {
            it("should store the contents of the X register at a memory location") {
                cpu.X = 0x12

                cpu.STX(0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("STY") {
            it("should store the contents of the Y register at a memory location") {
                cpu.Y = 0x12

                cpu.STY(0x1234)

                expect(cpu.memory.read(0x1234)).to(equal(0x12))
            }
        }

        describe("TAX") {
            it("should store the contents of the accumulator into the X register") {
                cpu.A = 0x12

                cpu.TAX()

                expect(cpu.X).to(equal(0x12))
            }
        }

        describe("TAY") {
            it("should store the contents of the accumulator into the Y register") {
                cpu.A = 0x12

                cpu.TAY()

                expect(cpu.Y).to(equal(0x12))
            }
        }

        describe("TSX") {
            it("should store the stack pointer in the X register") {
                cpu.SP = 0x12

                cpu.TSX()

                expect(cpu.X).to(equal(0x12))
            }
        }

        describe("TXA") {
            it("should store the X register in the Accumulator") {
                cpu.X = 0x12

                cpu.TXA()

                expect(cpu.A).to(equal(0x12))
            }
        }

        describe("TXS") {
            it("should set the Stack Pointer to the current value of the X register") {
                cpu.X = 0x12

                cpu.TXS()

                expect(cpu.SP).to(equal(0x12))
            }
        }

        describe("TYA") {
            it("should store the X register in the Accumulator") {
                cpu.Y = 0x12

                cpu.TYA()

                expect(cpu.A).to(equal(0x12))
            }
        }
    }
}
