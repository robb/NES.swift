@testable import NES

import Nimble
import Quick

class PPUSpec: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var CPU: NES.CPU {
            return console.CPU!
        }

        var PPU: NES.PPU {
            return console.PPU!
        }

        beforeEach {
            console = .consoleWithDummyMapper()
        }

        describe("Reading a write-only register") {
            it("should return the last value written to any register") {
                CPU.write(.PPUCTRLAddress, 0x0F)
                CPU.write(.PPUMASKAddress, 0xF0)

                expect(CPU.read(.PPUCTRLAddress)).to(equal(0xF0))
            }
        }

        describe("Having the CPU write to the PPUCTRL register") {
            beforeEach {
                CPU.write(.PPUCTRLAddress, 0x3E)
            }

            it("should update the PPUCTRL register") {
                expect(PPU.PPUCTRL).to(equal(0x3E))
            }

            it("should update the nametable offset") {
                expect(PPU.nametableOffset).to(equal(0x2800))
            }

            it("should update the VRAM address increment") {
                expect(PPU.VRAMAddressIncrement).to(equal(32))
            }

            it("should update the sprite pattern table address") {
                expect(PPU.spritePatternTableAddress).to(equal(0x1000))
            }

            it("should update the background pattern table address") {
                expect(PPU.backgroundPatternTableAddress).to(equal(0x1000))
            }

            it("should select large sprites") {
                expect(PPU.useLargeSprites).to(beTrue())
            }
        }

        describe("Having the CPU write to the PPUMASK register") {
            beforeEach {
                CPU.write(.PPUMASKAddress, 0xFF)
            }

            it("should update the PPUMASK register") {
                expect(PPU.PPUMASK).to(equal(0xFF))
            }

            it("should update the grayscale mode") {
                expect(PPU.grayscale).to(beTrue())
            }

            it("should update the left background visibility") {
                expect(PPU.showLeftBackground).to(beTrue())
            }

            it("should update the left sprite visibility") {
                expect(PPU.showLeftSprites).to(beTrue())
            }

            it("should update the background visiblity") {
                expect(PPU.showBackground).to(beTrue())
            }

            it("should update the sprite visibility") {
                expect(PPU.showSprites).to(beTrue())
            }

            it("should update the red tint") {
                expect(PPU.emphasizeRed).to(beTrue())
            }

            it("should update the greenTint") {
                expect(PPU.emphasizeGreen).to(beTrue())
            }

            it("should update the blueTint") {
                expect(PPU.emphasizeBlue).to(beTrue())
            }
        }

        describe("Having the CPU read the PPUSTATUS register") {
            beforeEach {
                PPU.spriteOverflow = true
                PPU.spriteZeroHit = true
                PPU.VBlankStarted = true
            }

            it("should be affected by the sprite overflow, sprite zero and VBlank flags") {
                expect(CPU.read(.PPUSTATUSAddress)).to(equal(0xE0))
            }

            it("should contain the most recently written value in the lower five bits") {
                CPU.write(.PPUCTRLAddress, 0x0F)

                expect(CPU.read(.PPUSTATUSAddress)).to(equal(0xEF))
            }

            it("should reset the write latch") {
                PPU.secondWrite = true

                CPU.read(.PPUSTATUSAddress)

                expect(PPU.secondWrite).to(beFalse())
            }

            it("should reset the VBlank flag") {
                CPU.read(.PPUSTATUSAddress)

                expect(PPU.VBlankStarted).to(beFalse())
            }
        }

        describe("Having the CPU write to the OAMADDR register") {
            beforeEach {
                CPU.write(.OAMADDRAddress, 0x3E)
            }

            it("should update the OAMADDR register") {
                expect(PPU.OAMADDR).to(equal(0x3E))
            }
        }
    }
}
