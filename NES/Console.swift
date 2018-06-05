import Foundation

public final class Console {
    private let cpu: CPU

    public var frames: Int {
        return ppu.frame
    }

    private let mapper: Mapper

    private let ppu: PPU

    public var screenData: Data {
        return Data(bytesNoCopy: ppu.frontBuffer.pixels.baseAddress!, count: ppu.frontBuffer.pixels.count, deallocator: .none)
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

        if ppu.nmiTriggered {
            ppu.nmiTriggered = false
            cpu.triggerNMI()
        }
    }

    public static let frequency = 1789773.0

    public func step(time: TimeInterval) {
        let target = cpu.cycles + Int(time * Console.frequency)

        while cpu.cycles < target {
            step()
        }
    }

    public var cycles: Int {
        return cpu.cycles
    }
}
