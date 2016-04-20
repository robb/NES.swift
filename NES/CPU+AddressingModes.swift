import Foundation

internal extension CPU {
    func absolute(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = read16(PC &+ 1)

        cycles += cyclesSpent
        PC += 3

        return address
    }

    func absolute(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = read16(PC &+ 1)
        let operand = read(address)

        cycles += cyclesSpent
        PC += 3

        return operand
    }

    func absoluteX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = read16(PC &+ 1) &+ Address(X)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    func absoluteX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = read16(PC &+ 1) &+ Address(X)
        let operand = read(address)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    func absoluteY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = read16(PC &+ 1) &+ Address(Y)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    func absoluteY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = read16(PC &+ 1) &+ Address(Y)
        let operand = read(address)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    func accumulator(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Void {
        cycles += cyclesSpent
        PC += 1

        return
    }

    func immediate(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let operand = read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    func implied(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Void {
        cycles += cyclesSpent
        PC += 1
    }

    func indexedIndirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = buggyRead16(UInt16(read(PC &+ 1) &+ X))
        let operand = read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    func indexedIndirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let direct = UInt16(read(PC &+ 1) &+ X)
        let address = buggyRead16(direct)

        cycles += cyclesSpent
        PC += 2

        return address
    }

    func indirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = read16(PC &+ 1)
        let operand = buggyRead16(address)

        cycles += cyclesSpent
        PC += 3

        return operand
    }

    func indirectIndexed(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = buggyRead16(Address(read(PC &+ 1))) &+ Address(Y)
        let operand = read(address)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    func indirectIndexed(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = buggyRead16(Address(read(PC &+ 1))) &+ Address(Y)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    func relative(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let offset = read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        return offset
    }

    func zeroPage(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(0, read(PC &+ 1))
        let operand = read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    func zeroPage(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(0, read(PC &+ 1))

        cycles += cyclesSpent
        PC += 2

        return address
    }

    func zeroPageX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(read(PC &+ 1) &+ X)
        let operand = read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    func zeroPageX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(read(PC &+ 1) &+ X)

        cycles += cyclesSpent
        PC += 2

        return address
    }

    func zeroPageY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(read(PC &+ 1) &+ Y)
        let operand = read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    func zeroPageY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(read(PC &+ 1) &+ Y)

        cycles += cyclesSpent
        PC += 2

        return address
    }
}
