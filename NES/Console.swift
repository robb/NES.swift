import Foundation

public final class Console {
    internal private(set) var cpu: CPU! = nil

    public var frames: Int {
        return ppu.frame
    }

    internal private(set) var mapper: IO! = nil

    internal private(set) var ppu: PPU! = nil

    public var screenData: Data {
        return ppu.frontBuffer.pixelData
    }

    public convenience init(cartridge: Cartridge) {
        precondition(cartridge.mapper == 000 || cartridge.mapper == 002)

        let mapper = Mapper002(cartridge: cartridge)

        self.init(mapper: mapper)
    }

    init(mapper: IO) {
        self.mapper = mapper

        cpu = CPU(console: self)
        ppu = PPU(console: self)

        cpu.pc = cpu.read16(0xFFFC)
    }

    public func step() {
        let before = cpu.cycles

        cpu.step()

        let after = cpu.cycles

        let PPUCycles = (after - before) * 3

        for _ in 0 ..< PPUCycles {
            ppu.step()
        }
    }

    public func step(time: TimeInterval) {
        let frequency = 1789773.0

        let target = cpu.cycles + Int(time * frequency)

        while cpu.cycles < target {
            step()
        }
    }
}
