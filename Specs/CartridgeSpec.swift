@testable import NES

import Nimble
import Quick

class CartridgeSpec: QuickSpec {
    override func spec() {
        describe("Loading a .nes file") {
            var cartridge: Cartridge! = .None

            beforeEach {
                let path = NSBundle(forClass: CartridgeSpec.self).pathForResource("nestest", ofType: "nes") ?? ""

                cartridge = Cartridge.load(path)
            }

            it("should not be .None") {
                expect(cartridge).notTo(beNil())
            }

            it("should have a mapper") {
                expect(cartridge.mapper).to(equal(0))
            }
        }
    }
}
