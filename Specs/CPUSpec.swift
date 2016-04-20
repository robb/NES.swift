@testable import NES

import Nimble
import Quick

class CPUSpec: QuickSpec {
    override func spec() {
        describe("A new CPU") {
            let cpu = CPU(memory: Memory(mapper: DummyMapper()))

            it("should initialize with no cycles") {
                expect(cpu.cycles).to(equal(0))
            }

            it("should have interrupts disabled") {
                expect(cpu.I).to(beTrue())
            }
        }

        describe("Performing a interrupt") {
            var CPU: NES.CPU! = nil

            beforeEach {
                // Set the entire RAM to `NOP` instructions.
                let RAM = Array<UInt8>(count: 0x10000, repeatedValue: 0x1A)

                let memory = Memory(mapper: DummyMapper(), RAM: RAM)

                CPU = NES.CPU(memory: memory)

                CPU.memory.write16(0xFFFA, 0x0200)
                CPU.memory.write16(0xFFFE, 0x0100)
            }

            describe("with the I flag set") {
                beforeEach {
                    CPU.I = true
                }

                describe("that is maskable") {
                    beforeEach {
                        CPU.triggerIRQ()
                        CPU.step()
                    }

                    it("should not have any effect") {
                        expect(CPU.PC).to(equal(0x0001))
                    }
                }

                describe("that is not maskable") {
                    beforeEach {
                        CPU.triggerNMI()
                        CPU.step()
                    }

                    it("should execute the NMI interrupt handler") {
                        expect(CPU.PC).to(equal(0x0201))
                    }
                }
            }

            describe("without the I flag set") {
                beforeEach {
                    CPU.I = false
                }

                describe("that is maskable") {
                    beforeEach {
                        CPU.triggerIRQ()
                        CPU.step()
                    }

                    it("should execute the IRQ interrupt handler") {
                        expect(CPU.PC).to(equal(0x0101))
                    }
                }

                describe("that is not maskable") {
                    beforeEach {
                        CPU.triggerNMI()
                        CPU.step()
                    }

                    it("should execute the NMI interrupt handler") {
                        expect(CPU.PC).to(equal(0x0201))
                    }
                }
            }
        }
    }
}
