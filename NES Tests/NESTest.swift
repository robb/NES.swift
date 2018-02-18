@testable import NES

import Nimble
import Quick

class NESTest: QuickSpec {
    override func spec() {
        var console: Console! = nil

        var cpu: CPU! {
            return console.cpu
        }

        let log: [ConsoleState] = loadLog()

        beforeEach {
            let path = Bundle(for: CartridgeSpec.self).path(forResource: "nestest", ofType: "nes") ?? ""

            let cartridge = Cartridge.load(path: path)

            console = Console(cartridge: cartridge!)
        }

        it("should pass the nestest.nes test") {
            cpu.pc = 0xC000

            for state in log.dropLast() {
                expect(console).to(match(state: state))

                console.step()
            }

            expect(console).to(match(state: log.last!))

            expect(cpu.pc).to(equal(0xC66E))

            expect(cpu.read(0x0002)).to(equal(0x00))
            expect(cpu.read(0x0003)).to(equal(0x00))
        }
    }
}
