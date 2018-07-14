@testable import NES

import Nimble
import Quick

class PPUSpec: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var cpu: CPU {
            return console.cpu
        }

        var ppu: PPU {
            return console.ppu
        }

        beforeEach {
            console = .consoleWithDummyMapper()
        }

        describe("Reading a write-only register") {
            it("should return the last value written to any register") {
                cpu.write(.ppuctrlAddress, 0x0F)
                cpu.write(.ppumaskAddress, 0xF0)

                expect(cpu.read(.ppuctrlAddress)).to(equal(0xF0))
            }
        }

        describe("Having the CPU write to the PPUCTRL register") {
            beforeEach {
                cpu.write(.ppuctrlAddress, 0x3E)
            }

            it("should update the PPUCTRL register") {
                expect(ppu.ppuctrl).to(equal(0x3E))
            }

            it("should update the nametable offset") {
                expect(ppu.nametableOffset).to(equal(0x2800))
            }

            it("should update the VRAM address increment") {
                expect(ppu.vramAddressIncrement).to(equal(32))
            }

            it("should update the sprite pattern table address") {
                expect(ppu.spritePatternTableAddress).to(equal(0x1000))
            }

            it("should update the background pattern table address") {
                expect(ppu.backgroundPatternTableAddress).to(equal(0x1000))
            }

            it("should select large sprites") {
                expect(ppu.useLargeSprites).to(beTrue())
            }
        }

        describe("Having the CPU write to the PPUMASK register") {
            beforeEach {
                cpu.write(.ppumaskAddress, 0xFF)
            }

            it("should update the PPUMASK register") {
                expect(ppu.ppumask).to(equal(0xFF))
            }

            it("should update the grayscale mode") {
                expect(ppu.grayscale).to(beTrue())
            }

            it("should update the left background visibility") {
                expect(ppu.showLeftBackground).to(beTrue())
            }

            it("should update the left sprite visibility") {
                expect(ppu.showLeftSprites).to(beTrue())
            }

            it("should update the background visiblity") {
                expect(ppu.showBackground).to(beTrue())
            }

            it("should update the sprite visibility") {
                expect(ppu.showSprites).to(beTrue())
            }

            it("should update the red tint") {
                expect(ppu.emphasizeRed).to(beTrue())
            }

            it("should update the greenTint") {
                expect(ppu.emphasizeGreen).to(beTrue())
            }

            it("should update the blueTint") {
                expect(ppu.emphasizeBlue).to(beTrue())
            }
        }

        describe("Having the CPU read the PPUSTATUS register") {
            beforeEach {
                ppu.spriteOverflow = true
                ppu.spriteZeroHit = true
                ppu.verticalBlankStarted = true
            }

            it("should be affected by the sprite overflow, sprite zero and VBlank flags") {
                expect(cpu.read(.ppustatusAddress)).to(equal(0xE0))
            }

            it("should contain the most recently written value in the lower five bits") {
                cpu.write(.ppuctrlAddress, 0x0F)

                expect(cpu.read(.ppustatusAddress)).to(equal(0xEF))
            }

            it("should reset the write latch") {
                ppu.secondWrite = true

                cpu.read(.ppustatusAddress)

                expect(ppu.secondWrite).to(beFalse())
            }

            it("should reset the VBlank flag") {
                cpu.read(.ppustatusAddress)

                expect(ppu.verticalBlankStarted).to(beFalse())
            }
        }

        describe("Having the CPU write to the OAMADDR register") {
            beforeEach {
                cpu.write(.oamaddrAddress, 0x3E)
            }

            it("should update the OAMADDR register") {
                expect(ppu.oamaddr).to(equal(0x3E))
            }
        }

        describe("Having the CPU write to the OAMDATA register") {
            beforeEach {
                cpu.write(.oamaddrAddress, 0x00)
                cpu.write(.oamdataAddress, 0xFF)
            }

            it("should update the OAM at the memory location in the OAMADDR register") {
                expect(ppu.oam[0x00]).to(equal(0xFF))
            }

            it("should increment value in OAMADDR") {
                expect(ppu.oamaddr).to(equal(0x01))
            }
        }

        describe("Having the CPU read from the OAMDATA register") {
            beforeEach {
                cpu.write(.oamaddrAddress, 0x00)

                ppu.oam[0x00] = 0xFF
            }

            it("should return the value of the OAM at the memory location in the OAMADDR register") {
                expect(cpu.read(.oamdataAddress)).to(equal(0xFF))
            }
        }

        describe("Having the CPU write to the PPUSCROLL register once") {
            beforeEach {
                cpu.write(.ppuscrollAddress, 0x7D)
            }

            it("should enabled the write latch") {
                expect(ppu.secondWrite).to(beTrue())
            }

            describe("and again") {
                beforeEach {
                    cpu.write(.ppuscrollAddress, 0x5E)
                }

                it("should update the horizontal scroll position") {
                    expect(ppu.fineX).to(equal(0x05))
                }

                it("should update the temporary VRAM address") {
                    expect(ppu.temporaryVRAMAddress).to(equal(0x616F))
                }
            }
        }

        describe("Having the CPU write to PPUSCROLL & PPUADDR") {
            beforeEach {
                cpu.write(.ppuscrollAddress, 0x7D)
                cpu.write(.ppuscrollAddress, 0x5E)

                cpu.write(.ppuaddrAddress, 0x3D)
                cpu.write(.ppuaddrAddress, 0xF0)
            }

            it("should update the VRAM address") {
                expect(ppu.vramAddress).to(equal(0x3DF0))
            }
        }

        describe("Having the CPU read PPUDATA") {
            beforeEach {
                ppu.vramAddress = 0x0000
                ppu.vramBuffer = 0xFF

                ppu.write(ppu.vramAddress, 0x12)
            }

            it("should return the buffered value first") {
                expect(cpu.read(.ppudataAddress)).to(equal(0xFF))
            }

            it("should update the buffer") {
                cpu.read(.ppudataAddress)

                expect(ppu.vramBuffer).to(equal(0x12))
            }

            it("should return the value at the current VRAM address on the second read") {
                cpu.read(.ppudataAddress)

                expect(cpu.read(.ppudataAddress)).to(equal(0x12))
            }

            describe("if the VRAM increment flag is not set") {
                beforeEach {
                    ppu.ppuctrl[2] = false
                }

                it("should increment the VRAM address by 1") {
                    cpu.read(.ppudataAddress)

                    expect(ppu.vramAddress).to(equal(0x0001))
                }
            }

            describe("if the VRAM increment flag is set") {
                beforeEach {
                    ppu.ppuctrl[2] = true
                }

                it("should increment the VRAM address by 32") {
                    cpu.read(.ppudataAddress)

                    expect(ppu.vramAddress).to(equal(0x0020))
                }
            }
        }

        describe("Having the CPU write to PPUDATA") {
            describe("if the VRAM increment flag is not set") {
                beforeEach {
                    ppu.ppuctrl[2] = false
                }

                it("should increment the VRAM address by 1") {
                    cpu.write(.ppudataAddress, 0x12)

                    expect(ppu.vramAddress).to(equal(0x0001))
                }
            }

            describe("if the VRAM increment flag is set") {
                beforeEach {
                    ppu.ppuctrl[2] = true
                }

                it("should increment the VRAM address by 32") {
                    cpu.write(.ppudataAddress, 0x12)

                    expect(ppu.vramAddress).to(equal(0x0020))
                }
            }
        }

        describe("Having the CPU write to OAMDMA") {
            it("should copy the given memory page to the OAM") {
                let values = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 256)
                values.assign(repeating: 0x23)

                cpu.ram[0x0400 ..< 0x0500] = values[values.startIndex ..< values.endIndex]

                cpu.write(.oamdmaAddress, 0x04)

                expect(Array(ppu.oam)).to(equal(Array(values)))
            }

            describe("if the PPU is on an even cycle") {
                beforeEach {
                    ppu.cycle = 0

                    cpu.write(.oamdmaAddress, 0x20)
                }

                it("should stall the CPU for 513 cycles") {
                    expect(cpu.stallCycles).to(equal(513))
                }
            }

            describe("if the PPU is on an odd cycle") {
                beforeEach {
                    ppu.cycle = 1

                    cpu.write(.oamdmaAddress, 0x20)
                }

                it("should stall the CPU for 514 cycles") {
                    expect(cpu.stallCycles).to(equal(514))
                }
            }
        }

        describe("Setting the VRAM address") {
            it("should update the coarse X position") {
                ppu.vramAddress = 0b0000_0000_0001_1111

                expect(ppu.coarseX).to(equal(0b0001_1111))
            }

            it("should update the coarse Y position") {
                ppu.vramAddress = 0b0000_0011_1110_0000

                expect(ppu.coarseY).to(equal(0b0001_1111))
            }

            it("should update the selected nametable") {
                ppu.vramAddress = 0b0000_1100_0000_0000

                expect(ppu.nametable).to(equal(0b0000_0011))
            }

            it("should update the fine Y position") {
                ppu.vramAddress = 0b0111_0000_0000_0000

                expect(ppu.fineY).to(equal(0b0000_0111))
            }

            it("should update the attribute address") {
                ppu.vramAddress = 0b0000_1011_1001_0100

                expect(ppu.attributeAddress).to(equal(0b0010_1011_1111_1101))
            }

            it("should update the tile address") {
                ppu.vramAddress = 0b0000_1100_1010_1010

                expect(ppu.tileAddress).to(equal(0b0010_1100_1010_1010))
            }
        }

        describe("incrementing the X position") {
            it("should increase the coarse X position") {
                ppu.coarseX = 0x00

                for _ in 0 ..< 3 {
                    ppu.incrementX()
                }

                expect(ppu.coarseX).to(equal(0x03))
            }

            it("should toggle the horizontal name table when wrapping") {
                ppu.coarseX = 0x1F
                ppu.nametable = 0x00

                ppu.incrementX()

                expect(ppu.coarseX).to(equal(0x00))
                expect(ppu.nametable).to(equal(0x01))
            }
        }

        describe("incrementing the Y position") {
            it("should increase the fine Y position") {
                ppu.fineY = 0x00
                ppu.coarseY = 0x00

                for _ in 0 ..< 3 {
                    ppu.incrementY()
                }

                expect(ppu.fineY).to(equal(0x03))
            }

            it("should increment the coarse Y position when wrapping") {
                ppu.fineY = 0x07
                ppu.coarseY = 0x00

                ppu.incrementY()

                expect(ppu.fineY).to(equal(0x00))
                expect(ppu.coarseY).to(equal(0x01))
            }

            it("should toggle the vertical name table when coarse Y rolls beyond 0x1D") {
                ppu.fineY = 0x07
                ppu.coarseY = 0x1D
                ppu.nametable = 0x00

                ppu.incrementY()

                expect(ppu.fineY).to(equal(0x00))
                expect(ppu.coarseY).to(equal(0x00))
                expect(ppu.nametable).to(equal(0x02))
            }
        }
    }
}
