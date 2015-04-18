import NES

import Nimble
import Quick

class NESTest: QuickSpec {
    override func spec() {
        var cpu: CPU! = nil

        beforeEach {
            let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

            let cartridge = Cartridge.load(path)

            cpu = CPU(memory: Memory(mapper: Mapper000(cartridge: cartridge!)))
        }

        it("should pass the nestest.nes test") {
            cpu.PC = 0xC000

            while (cpu.PC != 0xC66E) {
                cpu.step()
            }

            expect(cpu.memory.read(0x0002)).to(equal(0x00))
            expect(cpu.memory.read(0x0003)).to(equal(0x00))
        }
    }
}
