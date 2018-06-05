import NES

import XCTest

class PerformanceTest: XCTestCase {
    func testNESTest() {
        let path = Bundle(for: PerformanceTest.self).path(forResource: "nestest", ofType: "nes") ?? ""

        let cartridge = Cartridge.load(path: path)

        measure {
            let console = Console(cartridge: cartridge!, initialAddress: 0xC000)

            while console.cycles < 26547 {
                console.step()
            }
        }
    }

    func testPlumber() {
        let path = Bundle(for: PerformanceTest.self).path(forResource: "plumber", ofType: "nes") ?? ""

        let cartridge = Cartridge.load(path: path)!

        measure {
            let console = Console(cartridge: cartridge)

            console.step(time: 3)
        }
    }
}
