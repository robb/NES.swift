@testable import NES

import XCTest

class PerformanceTest: XCTestCase {
    func testPerformance() {
        let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

        let cartridge = Cartridge.load(path)

        let CPU = NES.CPU(mapper: Mapper000(cartridge: cartridge!))

        measureBlock {
            CPU.PC = 0xC000

            while (CPU.PC != 0xC66E) {
                CPU.step()
            }
        }
    }
}
