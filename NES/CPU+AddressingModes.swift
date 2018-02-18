import Foundation

internal extension CPU {
    func absolute() -> Address {
        return advanceProgramCounter()
    }

    func absolute() -> UInt8 {
        return read(advanceProgramCounter())
    }

    func absoluteX(incursPageBoundaryCost: Bool) -> Address {
        let address = advanceProgramCounter() &+ Address(X)

        if incursPageBoundaryCost && differentPages(address, address &- Address(X)) {
            cycles += 1
        }

        return address
    }

    func absoluteX(incursPageBoundaryCost: Bool) -> UInt8 {
        return read(absoluteX(incursPageBoundaryCost: incursPageBoundaryCost))
    }

    func absoluteY(incursPageBoundaryCost: Bool) -> Address {
        let address = advanceProgramCounter() &+ Address(Y)

        if incursPageBoundaryCost && differentPages(address, address &- Address(Y)) {
            cycles += 1
        }

        return address
    }

    func absoluteY(incursPageBoundaryCost: Bool) -> UInt8 {
        return read(absoluteY(incursPageBoundaryCost: incursPageBoundaryCost))
    }

    func accumulator() -> Void {
    }

    func immediate() -> UInt8 {
        return advanceProgramCounter()
    }

    func implied() -> Void {
    }

    func indexedIndirect() -> Address {
        let address = Address(advanceProgramCounter() &+ X)

        return buggyRead16(address)
    }

    func indexedIndirect() -> UInt8 {
        return read(indexedIndirect())
    }

    func indirect() -> Address {
        return buggyRead16(advanceProgramCounter())
    }

    func indirectIndexed(incursPageBoundaryCost: Bool) -> Address {
        let address = buggyRead16(Address(page: 0x00, offset: advanceProgramCounter())) &+ Address(Y)

        if incursPageBoundaryCost && differentPages(address, address &- Address(Y)) {
            cycles += 1
        }

        return address
    }

    func indirectIndexed(incursPageBoundaryCost: Bool) -> UInt8 {
        return read(indirectIndexed(incursPageBoundaryCost: incursPageBoundaryCost))
    }

    func relative() -> UInt8 {
        return advanceProgramCounter()
    }

    func zeroPage() -> UInt8 {
        let address = Address(page: 0, offset: advanceProgramCounter())

        return read(address)
    }

    func zeroPage() -> Address {
        return Address(page: 0, offset: advanceProgramCounter())
    }

    func zeroPageX() -> Address {
        return Address(page: 0, offset: advanceProgramCounter() &+ X)
    }

    func zeroPageX() -> UInt8 {
        return read(zeroPageX())
    }

    func zeroPageY() -> Address {
        return Address(page: 0, offset: advanceProgramCounter() &+ Y)
    }

    func zeroPageY() -> UInt8 {
        return read(zeroPageY())
    }
}
