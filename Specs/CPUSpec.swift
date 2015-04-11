import NES

import Nimble
import Quick

class CPUSpec: QuickSpec {
    override func spec() {
        describe("A new CPU") {
            let cpu = CPU()

            it("should initialize with no cycles") {
                expect(cpu.cycles).to(equal(0))
            }

            it("should have interrupts disabled") {
                expect(cpu.I).to(beTrue())
            }
        }
    }
}
