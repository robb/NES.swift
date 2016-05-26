@testable import NES

import Nimble
import Quick

class CPUSpec: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var CPU: NES.CPU {
            return console.CPU!
        }

        beforeEach {
            console = .consoleWithDummyMapper()
        }

        describe("A new CPU") {
            it("should initialize with no cycles") {
                expect(CPU.cycles).to(equal(0))
            }

            it("should have interrupts disabled") {
                expect(CPU.I).to(beTrue())
            }
        }

        describe("Stepping a CPU") {
            beforeEach {
                // Fill the RAM with NOPs
                let RAM = Array<UInt8>(count: 0x0800, repeatedValue: 0x1A)

                CPU.RAM[RAM.startIndex ..< RAM.endIndex] = RAM[RAM.startIndex ..< RAM.endIndex]
                CPU.PC = 0x0200

                expect(CPU.cycles).to(equal(0))
            }

            it("should increase the cycle count") {
                CPU.step()

                expect(CPU.cycles).to(equal(2))
            }

            it("should advance the program counter") {
                CPU.step()

                expect(CPU.PC).to(equal(0x0201))
            }

            describe("that is stalled") {
                beforeEach {
                    CPU.stallCycles = 1
                }

                it("should not perform any work") {
                    CPU.step()

                    expect(CPU.PC).to(equal(0x0200))
                }

                it("should decrease the stall cycle counter") {
                    CPU.step()

                    expect(CPU.stallCycles).to(equal(0))
                }

                it("should increase the cycle count") {
                    CPU.step()

                    expect(CPU.cycles).to(equal(1))
                }
            }
        }

        describe("Performing an interrupt") {
            beforeEach {
                // Set the entire RAM to `NOP` instructions.
                let RAM = Array<UInt8>(count: 0x0800, repeatedValue: 0x1A)

                CPU.RAM[RAM.startIndex ..< RAM.endIndex] = RAM[RAM.startIndex ..< RAM.endIndex]

                CPU.write16(NES.CPU.IRQInterruptVector, 0x0100)

                CPU.write16(NES.CPU.NMIInterruptVector, 0x0200)
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
