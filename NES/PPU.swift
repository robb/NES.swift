import Foundation

internal final class PPU {
    /// The PPU Control register.
    var ppuctrl: UInt8 = 0

    /// The PPU Mask register.
    var ppumask: UInt8 = 0

    /// The PPU Status register.
    ///
    /// Setting the lower five bit has no effect.
    var ppustatus: UInt8 = 0

    /// The OAM Address Port register.
    var oamaddr: UInt8 = 0

    /// The OAM Data Port register.
    ///
    /// This property proxies the PPU's OAM at the address held by OAMADDR.
    var oamdata: UInt8 {
        get {
            return oam[oamaddr]
        }
        set {
            oam[oamaddr] = newValue
        }
    }

    /// The PPU scrolling position register.
    var ppuscroll: UInt8 = 0

    /// The PPU address register.
    var ppuaddr: UInt8 = 0

    /// The PPU data port.
    ///
    /// This property proxies the PPU's VRAM at the address held by VRAMAddress.
    var ppudata: UInt8 {
        get {
            return read(vramAddress)
        }
        set {
            write(vramAddress, newValue)
        }
    }

    /// This value holds buffered reads from PPUDATA.
    var vramBuffer: UInt8 = 0

    /// The buffered PPU data port.
    var bufferedPPUDATA: UInt8 {
        var data = ppudata

        if vramAddress < 0x3F00 {
            swap(&data, &vramBuffer)
        } else {
            vramBuffer = read(vramAddress &- 0x1000)
        }

        return data
    }

    /// The OAM DMA register.
    var oamdma: UInt8 = 0

    /// Holds the last value written to any of the above registers.
    ///
    /// Setting this will also affect the five lowest bits of PPUSTATUS.
    var register: UInt8 = 0 {
        didSet {
            ppustatus = (ppustatus & 0xE0) | (register & 0x1F)
        }
    }

    var cycle: Int = 0

    var scanLine: Int = 241

    var frame: Int = 0

    var vramAddress: Address = 0

    var temporaryVRAMAddress: Address = 0

    /// Bits 0 through 2 of `PPUSCROLL` represent the fine X position.
    var fineX: UInt8 = 0

    var highTileByte: UInt8 = 0

    var lowTileByte: UInt8 = 0

    var attributeTableByte: UInt8 = 0

    var nameTableByte: UInt8 = 0

    /// Toggled by writing to PPUSCROLL or PPUADDR, cleared by reading
    /// PPUSTATUS.
    var secondWrite: Bool = false

    /// The console this CPU is owned by.
    unowned let console: Console

    /// The CPU.
    var cpu: CPU! {
        return console.cpu
    }

    var frontBuffer: ScreenBuffer = ScreenBuffer()

    var backBuffer: ScreenBuffer = ScreenBuffer()

    /// The mapper the PPU reads from.
    var mapper: IO! {
        return console.mapper
    }

    /// The VRAM the PPU reads from.
    var vram: Data

    /// The Object Attribute Memory.
    var oam: Data = Data(repeating: 0x00, count: 0x0100)

    /// The palette data.
    var palette: [UInt8] = [
        0x09, 0x01, 0x00, 0x01, 0x00, 0x02, 0x02, 0x0D,
        0x08, 0x10, 0x08, 0x24, 0x00, 0x00, 0x04, 0x2C,
        0x09, 0x01, 0x34, 0x03, 0x00, 0x04, 0x00, 0x14,
        0x08, 0x3A, 0x00, 0x02, 0x00, 0x20, 0x2C, 0x08
    ]

    init(console: Console, vram: Data = Data(repeating: 0x00, count: 0x800)) {
        self.console = console
        self.vram = vram
    }
}

internal extension PPU {
    /// Must be called after the CPU has written PPUCTRL.
    func didWritePPUCTRL() {
        if nmiEnabled && verticalBlankStarted {
            cpu.triggerNMI()
        }
    }

    /// Must be called after the CPU has read PPUSTATUS.
    func didReadPPUSTATUS() {
        verticalBlankStarted = false
        secondWrite = false
    }

    /// Must be called after the CPU has written OAMDATA.
    func didWriteOAMDATA() {
        oamaddr = oamaddr &+ 1
    }

    /// Must be called after the CPU has written PPUSCROLL.
    func didWritePPUSCROLL() {
        if !secondWrite {
            temporaryVRAMAddress = (temporaryVRAMAddress & 0xFFE0) | (UInt16(ppuscroll) >> 3)
            fineX = ppuscroll & 0x07
        } else {
            temporaryVRAMAddress = (temporaryVRAMAddress & 0x8FFF) | UInt16(ppuscroll & 0x07) << 12
            temporaryVRAMAddress = (temporaryVRAMAddress & 0xFC1F) | UInt16(ppuscroll & 0xF8) << 2
        }

        secondWrite = !secondWrite
    }

    /// Must be called after the CPU has written PPUADDR.
    func didWritePPUADDR() {
        if !secondWrite {
            temporaryVRAMAddress = (temporaryVRAMAddress & 0x80FF) | UInt16(ppuaddr & 0x3F) << 8
        } else {
            temporaryVRAMAddress = (temporaryVRAMAddress & 0xFF00) | UInt16(ppuaddr)
            vramAddress = temporaryVRAMAddress
        }

        secondWrite = !secondWrite
    }

    /// Must be called after the CPU has read PPUDATA.
    func didReadPPUDATA() {
        vramAddress += vramAddressIncrement
    }

    /// Must be called after the CPU has written PPUDATA.
    func didWritePPUDATA() {
        vramAddress += vramAddressIncrement
    }

    /// Must be called after the CPU has written OAMDMA.
    func didWriteOAMDMA() {
        for offset: UInt8 in 0x00 ... 0xFF {
            let address = Address(page: oamdma, offset: offset)

            oam[oamaddr] = cpu.read(address)

            oamaddr = oamaddr &+ 1
        }

        cpu.stallCycles += cycle % 2 == 0 ? 513 : 514
    }
}
