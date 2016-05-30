@testable import NES

import XCTest

class PerformanceTest: XCTestCase {
    func testPerformance() {
        let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

        let cartridge = Cartridge.load(path)

        let console = Console(cartridge: cartridge!)

        measureBlock {
            console.CPU.PC = 0xC000

            while (console.CPU.PC != 0xC66E) {
                console.step()
            }
        }
    }
}
