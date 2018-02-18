import Foundation

public final class Console {
    internal private(set) var cpu: CPU! = nil

    public var frames: Int {
        return ppu.frame
    }

    internal let mapper: Mapper

    internal private(set) var ppu: PPU! = nil

    public var screenData: Data {
        return ppu.frontBuffer.pixels
    }

    public convenience init(cartridge: Cartridge, initialAddress: UInt16? = nil) {
        precondition(cartridge.mapper == 000 || cartridge.mapper == 002)

        let mapper = Mapper002(cartridge: cartridge)

        self.init(mapper: mapper)

        if let pc = initialAddress {
            cpu.pc = pc
        }
    }

    init(mapper: Mapper) {
        self.mapper = mapper

        cpu = CPU(mapper: mapper)
        ppu = PPU(mapper: mapper)

        cpu.ppu = ppu
        ppu.cpu = cpu

        cpu.pc = cpu.read16(0xFFFC)
    }

    deinit {
        cpu.ppu = nil
        ppu.cpu = nil
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

    public var cycles: Int {
        return cpu.cycles
    }
}
