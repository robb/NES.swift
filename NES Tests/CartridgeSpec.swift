@testable import NES

import Nimble
import Quick

class CartridgeSpec: QuickSpec {
    override func spec() {
        describe("Loading a .nes file") {
            var cartridge: Cartridge! = .none

            beforeEach {
                let path = Bundle(for: CartridgeSpec.self).path(forResource: "nestest", ofType: "nes") ?? ""

                cartridge = Cartridge.load(path: path)
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
