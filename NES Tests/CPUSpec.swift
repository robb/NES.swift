@testable import NES

import Nimble
import Quick

class CPUSpec: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var cpu: CPU {
            return console.CPU!
        }

        beforeEach {
            console = .consoleWithDummyMapper()
        }

        describe("A new CPU") {
            it("should initialize with no cycles") {
                expect(cpu.cycles).to(equal(0))
            }

            it("should have interrupts disabled") {
                expect(cpu.I).to(beTrue())
            }
        }

        describe("Stepping a CPU") {
            beforeEach {
                // Fill the RAM with NOPs
                let RAM = Array<UInt8>(count: 0x0800, repeatedValue: 0x1A)

                cpu.RAM[RAM.startIndex ..< RAM.endIndex] = RAM[RAM.startIndex ..< RAM.endIndex]
                cpu.PC = 0x0200

                expect(cpu.cycles).to(equal(0))
            }

            it("should increase the cycle count") {
                cpu.step()

                expect(cpu.cycles).to(equal(2))
            }

            it("should advance the program counter") {
                cpu.step()

                expect(cpu.PC).to(equal(0x0201))
            }

            describe("that is stalled") {
                beforeEach {
                    cpu.stallCycles = 1
                }

                it("should not perform any work") {
                    cpu.step()

                    expect(cpu.PC).to(equal(0x0200))
                }

                it("should decrease the stall cycle counter") {
                    cpu.step()

                    expect(cpu.stallCycles).to(equal(0))
                }

                it("should increase the cycle count") {
                    cpu.step()

                    expect(cpu.cycles).to(equal(1))
                }
            }
        }

        describe("Performing an interrupt") {
            beforeEach {
                // Set the entire RAM to `NOP` instructions.
                let RAM = Array<UInt8>(count: 0x0800, repeatedValue: 0x1A)

                cpu.RAM[RAM.startIndex ..< RAM.endIndex] = RAM[RAM.startIndex ..< RAM.endIndex]

                cpu.write16(NES.CPU.IRQInterruptVector, 0x0100)

                cpu.write16(NES.CPU.NMIInterruptVector, 0x0200)
            }

            describe("with the I flag set") {
                beforeEach {
                    cpu.I = true
                }

                describe("that is maskable") {
                    beforeEach {
                        cpu.triggerIRQ()
                        cpu.step()
                    }

                    it("should not have any effect") {
                        expect(cpu.PC).to(equal(0x0001))
                    }
                }

                describe("that is not maskable") {
                    beforeEach {
                        cpu.triggerNMI()
                        cpu.step()
                    }

                    it("should execute the NMI interrupt handler") {
                        expect(cpu.PC).to(equal(0x0201))
                    }
                }
            }

            describe("without the I flag set") {
                beforeEach {
                    cpu.I = false
                }

                describe("that is maskable") {
                    beforeEach {
                        cpu.triggerIRQ()
                        cpu.step()
                    }

                    it("should execute the IRQ interrupt handler") {
                        expect(cpu.PC).to(equal(0x0101))
                    }
                }

                describe("that is not maskable") {
                    beforeEach {
                        cpu.triggerNMI()
                        cpu.step()
                    }

                    it("should execute the NMI interrupt handler") {
                        expect(cpu.PC).to(equal(0x0201))
                    }
                }
            }
        }
    }
}
