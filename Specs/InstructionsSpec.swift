import NES

import Nimble
import Quick

class InstructionsSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!

        beforeEach {
            cpu = CPU()
        }

        describe("AND") {
            it("should perform bitwise AND on A and the contents of a byte of memory") {
                cpu.A = 0xF5
                cpu.memory.write(0x2000, 0x5F)
                cpu.AND(0x2000)

                expect(cpu.A).to(equal(0x55))
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
                expect(cpu.breakCommand).to(beTrue())
            }
        }

        describe("ORA") {
            it("should perform bitwise OR on A and the contents of a byte of memory") {
                cpu.A = 0x01
                cpu.memory.write(0x2000, 0xF0)
                cpu.ORA(0x2000)

                expect(cpu.A).to(equal(0xF1))
            }
        }

        describe("PHP") {
            beforeEach {
                cpu.P = 0x24
                cpu.PHP()
            }

            it("should push the processor status to the stack") {
                let P = cpu.memory.read(CPU.StackOffset | UInt16(cpu.SP + 1))

                expect(P).to(equal(0x24))
            }
        }

        describe("SEI") {
            beforeEach {
                cpu.SEI()
            }

            it("should set the interrupt disable flag") {
                expect(cpu.interruptDisable).to(beTrue())
            }
        }
    }
}
