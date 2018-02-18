@testable import NES

import Nimble
import Quick

class NESTest: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var cpu: CPU! {
            return console.CPU
        }

        let log: [ConsoleState] = loadLog()

        beforeEach {
            let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

            let cartridge = Cartridge.load(path)

            console = Console(cartridge: cartridge!)
        }

        it("should pass the nestest.nes test") {
            cpu.PC = 0xC000

            for state in log.dropLast() {
                expect(console).to(match(state))

                console.step()
            }

            expect(console).to(match(log.last))

            expect(cpu.PC).to(equal(0xC66E))

            expect(cpu.read(0x0002)).to(equal(0x00))
            expect(cpu.read(0x0003)).to(equal(0x00))
        }
    }
}
