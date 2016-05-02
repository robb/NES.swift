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

        describe("Having the CPU write to memory address 0x2000") {
            beforeEach {
                CPU.write(0x2000, 0x3E)
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

        describe("Having the CPU write to memory address 0x2001") {
            beforeEach {
                CPU.write(0x2001, 0xFF)
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
    }
}
