import Foundation

public final class Console {
    internal private(set) var CPU: NES.CPU! = nil

    public var frames: Int {
        return PPU.frame
    }

    internal private(set) var mapper: IO! = nil

    internal private(set) var PPU: NES.PPU! = nil

    public var screenData: NSData {
        return PPU.frontBuffer.pixelData
    }

    public convenience init(cartridge: Cartridge) {
        precondition(cartridge.mapper == 000 || cartridge.mapper == 002)

        let mapper = Mapper002(cartridge: cartridge)

        self.init(mapper: mapper)
    }

    init(mapper: IO) {
        self.mapper = mapper

        CPU = NES.CPU(console: self)
        PPU = NES.PPU(console: self)

        CPU.PC = CPU.read16(0xFFFC)
    }

    public func step() {
        let before = CPU.cycles

        CPU.step()

        let after = CPU.cycles

        let PPUCycles = (after - before) * 3

        for _ in 0 ..< PPUCycles {
            PPU.step()
        }
    }

    public func step(time: TimeInterval) {
        let frequency = 1789773.0

        let target = CPU.cycles + Int(time * frequency)

        while CPU.cycles < target {
            step()
        }
    }
}
