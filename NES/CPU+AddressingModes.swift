import Foundation

internal extension CPU {
    func absolute() -> Address {
        advanceProgramCounter()
    }

    func absolute() -> UInt8 {
        read(advanceProgramCounter())
    }

    func absoluteX(_ incursPageBoundaryCost: Bool = false) -> Address {
        let address = advanceProgramCounter() &+ Address(x)

        if incursPageBoundaryCost && differentPages(address, address &- Address(x)) {
            cycles += 1
        }

        return address
    }

    func absoluteX(_ incursPageBoundaryCost: Bool = false) -> UInt8 {
        read(absoluteX(incursPageBoundaryCost))
    }

    func absoluteY(_ incursPageBoundaryCost: Bool = false) -> Address {
        let address = advanceProgramCounter() &+ Address(y)

        if incursPageBoundaryCost && differentPages(address, address &- Address(y)) {
            cycles += 1
        }

        return address
    }

    func absoluteY(_ incursPageBoundaryCost: Bool = false) -> UInt8 {
        read(absoluteY(incursPageBoundaryCost))
    }

    func accumulator() -> Void {
    }

    func immediate() -> UInt8 {
        advanceProgramCounter()
    }

    func implied() -> Void {
    }

    func indexedIndirect() -> Address {
        let address = Address(advanceProgramCounter() &+ x)

        return buggyRead16(address)
    }

    func indexedIndirect() -> UInt8 {
        read(indexedIndirect())
    }

    func indirect() -> Address {
        buggyRead16(advanceProgramCounter())
    }

    func indirectIndexed(_ incursPageBoundaryCost: Bool = false) -> Address {
        let address = buggyRead16(Address(page: 0x00, offset: advanceProgramCounter())) &+ Address(y)

        if incursPageBoundaryCost && differentPages(address, address &- Address(y)) {
            cycles += 1
        }

        return address
    }

    func indirectIndexed(_ incursPageBoundaryCost: Bool = false) -> UInt8 {
        read(indirectIndexed(incursPageBoundaryCost))
    }

    func relative() -> UInt8 {
        advanceProgramCounter()
    }

    func zeroPage() -> UInt8 {
        let address = Address(page: 0, offset: advanceProgramCounter())

        return read(address)
    }

    func zeroPage() -> Address {
        Address(page: 0, offset: advanceProgramCounter())
    }

    func zeroPageX() -> Address {
        Address(page: 0, offset: advanceProgramCounter() &+ x)
    }

    func zeroPageX() -> UInt8 {
        read(zeroPageX())
    }

    func zeroPageY() -> Address {
        Address(page: 0, offset: advanceProgramCounter() &+ y)
    }

    func zeroPageY() -> UInt8 {
        read(zeroPageY())
    }
}
