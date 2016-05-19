@testable import NES

import Nimble
import Quick

class NESTest: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var CPU: NES.CPU! {
            return console.CPU
        }

        let log: [ConsoleState] = loadLog()

        beforeEach {
            let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

            let cartridge = Cartridge.load(path)

            console = Console(cartridge: cartridge!)
        }

        it("should pass the nestest.nes test") {
            CPU.PC = 0xC000

            for state in log.dropLast() {
                expect(CPU).to(match(state))

                CPU.step()
            }

            expect(CPU).to(match(log.last))

            expect(CPU.PC).to(equal(0xC66E))

            expect(CPU.read(0x0002)).to(equal(0x00))
            expect(CPU.read(0x0003)).to(equal(0x00))
        }
    }
}
