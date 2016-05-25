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

        describe("Having the CPU write to the OAMDATA register") {
            beforeEach {
                CPU.write(.OAMADDRAddress, 0x00)
                CPU.write(.OAMDATAAddress, 0xFF)
            }

            it("should update the OAM at the memory location in the OAMADDR register") {
                expect(PPU.OAM[0x00]).to(equal(0xFF))
            }

            it("should increment value in OAMADDR") {
                expect(PPU.OAMADDR).to(equal(0x01))
            }
        }

        describe("Having the CPU read from the OAMDATA register") {
            beforeEach {
                CPU.write(.OAMADDRAddress, 0x00)

                PPU.OAM[0x00] = 0xFF
            }

            it("should return the value of the OAM at the memory location in the OAMADDR register") {
                expect(CPU.read(.OAMDATAAddress)).to(equal(0xFF))
            }
        }

        describe("Having the CPU write to the PPUSCROLL register once") {
            beforeEach {
                CPU.write(.PPUSCROLLAddress, 0x7D)
            }

            it("should enabled the write latch") {
                expect(PPU.secondWrite).to(beTrue())
            }

            describe("and again") {
                beforeEach {
                    CPU.write(.PPUSCROLLAddress, 0x5E)
                }

                it("should update the horizontal scroll position") {
                    expect(PPU.fineX).to(equal(0x05))
                }

                it("should update the temporary VRAM address") {
                    expect(PPU.temporaryVRAMAddress).to(equal(0x616F))
                }
            }
        }

        describe("Having the CPU write to PPUSCROLL & PPUADDR") {
            beforeEach {
                CPU.write(.PPUSCROLLAddress, 0x7D)
                CPU.write(.PPUSCROLLAddress, 0x5E)

                CPU.write(.PPUADDRAddress, 0x3D)
                CPU.write(.PPUADDRAddress, 0xF0)
            }

            it("should update the VRAM address") {
                expect(PPU.VRAMAddress).to(equal(0x3DF0))
            }
        }

        describe("Having the CPU read PPUDATA") {
            beforeEach {
                PPU.VRAMAddress = 0x0000
                PPU.VRAMBuffer = 0xFF

                PPU.write(PPU.VRAMAddress, 0x12)
            }

            it("should return the buffered value first") {
                expect(CPU.read(.PPUDATAAddress)).to(equal(0xFF))
            }

            it("should update the buffer") {
                CPU.read(.PPUDATAAddress)

                expect(PPU.VRAMBuffer).to(equal(0x12))
            }

            it("should return the value at the current VRAM address on the second read") {
                CPU.read(.PPUDATAAddress)

                expect(CPU.read(.PPUDATAAddress)).to(equal(0x12))
            }

            describe("if the VRAM increment flag is not set") {
                beforeEach {
                    PPU.PPUCTRL[2] = false
                }

                it("should increment the VRAM address by 1") {
                    CPU.read(.PPUDATAAddress)

                    expect(PPU.VRAMAddress).to(equal(0x0001))
                }
            }

            describe("if the VRAM increment flag is set") {
                beforeEach {
                    PPU.PPUCTRL[2] = true
                }

                it("should increment the VRAM address by 32") {
                    CPU.read(.PPUDATAAddress)

                    expect(PPU.VRAMAddress).to(equal(0x0020))
                }
            }
        }

        describe("Having the CPU write to PPUDATA") {
            describe("if the VRAM increment flag is not set") {
                beforeEach {
                    PPU.PPUCTRL[2] = false
                }

                it("should increment the VRAM address by 1") {
                    CPU.write(.PPUDATAAddress, 0x12)

                    expect(PPU.VRAMAddress).to(equal(0x0001))
                }
            }

            describe("if the VRAM increment flag is set") {
                beforeEach {
                    PPU.PPUCTRL[2] = true
                }

                it("should increment the VRAM address by 32") {
                    CPU.write(.PPUDATAAddress, 0x12)

                    expect(PPU.VRAMAddress).to(equal(0x0020))
                }
            }
        }

        describe("Having the CPU write to OAMDMA") {
            it("should copy the given memory page to the OAM") {
                let values = Array<UInt8>(count: 256, repeatedValue: 0x23)

                CPU.RAM[0x0400..<0x0500] = ArraySlice(values)

                CPU.write(.OAMDMAAddress, 0x04)

                expect(PPU.OAM).to(equal(values))
            }

            describe("if the PPU is on an even cycle") {
                beforeEach {
                    PPU.cycle = 0

                    CPU.write(.OAMDMAAddress, 0x20)
                }

                it("should stall the CPU for 513 cycles") {
                    expect(CPU.stallCycles).to(equal(513))
                }
            }

            describe("if the PPU is on an odd cycle") {
                beforeEach {
                    PPU.cycle = 1

                    CPU.write(.OAMDMAAddress, 0x20)
                }

                it("should stall the CPU for 514 cycles") {
                    expect(CPU.stallCycles).to(equal(514))
                }
            }
        }

        describe("Setting the VRAM address") {
            it("should update the coarse X position") {
                PPU.VRAMAddress = 0b0000_0000_0001_1111

                expect(PPU.coarseX).to(equal(0b0001_1111))
            }

            it("should update the coarse Y position") {
                PPU.VRAMAddress = 0b0000_0011_1110_0000

                expect(PPU.coarseY).to(equal(0b0001_1111))
            }

            it("should update the selected nametable") {
                PPU.VRAMAddress = 0b0000_1100_0000_0000

                expect(PPU.nametable).to(equal(0b0000_0011))
            }

            it("should update the fine Y position") {
                PPU.VRAMAddress = 0b0111_0000_0000_0000

                expect(PPU.fineY).to(equal(0b0000_0111))
            }

            it("should update the attribute address") {
                PPU.VRAMAddress = 0b0000_1011_1001_0100

                expect(PPU.attributeAddress).to(equal(0b0010_1011_1111_1101))
            }

            it("should update the tile address") {
                PPU.VRAMAddress = 0b0000_1100_1010_1010

                expect(PPU.tileAddress).to(equal(0b0010_1100_1010_1010))
            }
        }

        describe("incrementing the X position") {
            it("should increase the coarse X position") {
                PPU.coarseX = 0x00

                for _ in 0 ..< 3 {
                    PPU.incrementX()
                }

                expect(PPU.coarseX).to(equal(0x03))
            }

            it("should toggle the horizontal name table when wrapping") {
                PPU.coarseX = 0x1F
                PPU.nametable = 0x00

                PPU.incrementX()

                expect(PPU.coarseX).to(equal(0x00))
                expect(PPU.nametable).to(equal(0x01))
            }
        }

        describe("incrementing the Y position") {
            it("should increase the fine Y position") {
                PPU.fineY = 0x00
                PPU.coarseY = 0x00

                for _ in 0 ..< 3 {
                    PPU.incrementY()
                }

                expect(PPU.fineY).to(equal(0x03))
            }

            it("should increment the coarse Y position when wrapping") {
                PPU.fineY = 0x07
                PPU.coarseY = 0x00

                PPU.incrementY()

                expect(PPU.fineY).to(equal(0x00))
                expect(PPU.coarseY).to(equal(0x01))
            }

            it("should toggle the vertical name table when coarse Y rolls beyond 0x1D") {
                PPU.fineY = 0x07
                PPU.coarseY = 0x1D
                PPU.nametable = 0x00

                PPU.incrementY()

                expect(PPU.fineY).to(equal(0x00))
                expect(PPU.coarseY).to(equal(0x00))
                expect(PPU.nametable).to(equal(0x02))
            }
        }
    }
}
