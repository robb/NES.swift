import NES

import Nimble
import Quick

class InstructionsSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!

        beforeEach {
            cpu = CPU()
        }

        describe("BRK") {
            beforeEach {
                cpu.PC = 0xABBA
                cpu.P = 0x24
                cpu.memory[0xFFFE] = UInt16(0x1234)
                cpu.BRK()
            }

            it("should push the program counter to the stack") {
                let PC = cpu.memory[CPU.StackOffset | UInt16(cpu.SP + 2)] as UInt16

                expect(PC).to(equal(0xABBA))
            }

            it("should push the processor status to the stack") {
                let P: UInt8 = cpu.memory[CPU.StackOffset | UInt16(cpu.SP + 1)]

                expect(P).to(equal(0x24))
            }

            it("should load the IRQ interrupt vector into the PC register") {
                expect(cpu.PC).to(equal(0x1234))
            }

            it("should set the break flag") {
                expect(cpu.breakCommand).to(beTrue())
            }
        }

        describe("PHP") {
            beforeEach {
                cpu.P = 0x24
                cpu.PHP()
            }

            it("should push the processor status to the stack") {
                let P: UInt8 = cpu.memory[CPU.StackOffset | UInt16(cpu.SP + 1)]

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
