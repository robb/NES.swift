@testable import NES

import XCTest

class PerformanceTest: XCTestCase {
    func testPerformance() {
        let path = Bundle(for: CartridgeSpec.self).path(forResource: "nestest", ofType: "nes") ?? ""

        let cartridge = Cartridge.load(path: path)

        let console = Console(cartridge: cartridge!)

        measure {
            console.cpu.pc = 0xC000

            while (console.cpu.pc != 0xC66E) {
                console.step()
            }
        }
    }
}
