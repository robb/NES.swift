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

        describe("EOR") {
            it("should perform bitwise XOR on A and a value") {
                cpu.A = 0xF5

                cpu = EOR(cpu, 0x5F)

                expect(cpu.A).to(equal(0xAA))
            }
        }

        describe("LDA") {
            it("should store a value in the A register") {
                cpu = LDA(cpu, 0x5F)

                expect(cpu.A).to(equal(0x5F))
            }
        }

        describe("ORA") {
            it("should perform bitwise OR on A and a value") {
                cpu.A = 0x01

                cpu = ORA(cpu, 0xF0)

                expect(cpu.A).to(equal(0xF1))
            }
        }

        describe("PHP") {
            beforeEach {
                cpu.P = 0x24

                cpu = PHP(cpu)
            }

            it("should push the processor status to the stack") {
                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("SEI") {
            beforeEach {
                cpu = SEI(cpu)
            }

            it("should set the interrupt disable flag") {
                expect(cpu.interruptDisable).to(beTrue())
            }
        }
    }
}
