import Foundation

public extension CPU {
    public mutating func absolute(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = memory.read16(PC &+ 1)

        cycles += cyclesSpent
        PC += 3

        return address
    }

    public mutating func absolute(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = memory.read16(PC &+ 1)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 3

        return operand
    }

    public mutating func absoluteX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = memory.read16(PC &+ 1) &+ Address(X)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    public mutating func absoluteX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = memory.read16(PC &+ 1) &+ Address(X)
        let operand = memory.read(address)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    public mutating func absoluteY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = memory.read16(PC &+ 1) &+ Address(Y)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    public mutating func absoluteY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = memory.read16(PC &+ 1) &+ Address(Y)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    public mutating func accumulator(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Void {
        cycles += cyclesSpent
        PC += 1

        return
    }

    public mutating func immediate(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let operand = memory.read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    public mutating func implied(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Void {
        cycles += cyclesSpent
        PC += 1
    }

    public mutating func indexedIndirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = memory.buggyRead16(UInt16(memory.read(PC &+ 1) &+ X))
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    public mutating func indexedIndirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let direct = UInt16(memory.read(PC &+ 1) &+ X)
        let address = memory.buggyRead16(direct)

        cycles += cyclesSpent
        PC += 2

        return address
    }

    public mutating func indirect(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = memory.read16(PC &+ 1)
        let operand = memory.buggyRead16(address)

        cycles += cyclesSpent
        PC += 3

        return operand
    }

    public mutating func indirectIndexed(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = memory.buggyRead16(Address(memory.read(PC &+ 1))) &+ Address(Y)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return operand
    }

    public mutating func indirectIndexed(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = memory.buggyRead16(Address(memory.read(PC &+ 1))) &+ Address(Y)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        return address
    }

    public mutating func relative(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let offset = memory.read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        return offset
    }

    public mutating func zeroPage(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(0, memory.read(PC &+ 1))
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    public mutating func zeroPage(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(0, memory.read(PC &+ 1))

        cycles += cyclesSpent
        PC += 2

        return address
    }

    public mutating func zeroPageX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(memory.read(PC &+ 1) &+ X)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    public mutating func zeroPageX(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(memory.read(PC &+ 1) &+ X)

        cycles += cyclesSpent
        PC += 2

        return address
    }

    public mutating func zeroPageY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> UInt8 {
        let address = Address(memory.read(PC &+ 1) &+ Y)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        return operand
    }

    public mutating func zeroPageY(cyclesSpent: UInt64, _ pageBoundaryCost: UInt64) -> Address {
        let address = Address(memory.read(PC &+ 1) &+ Y)

        cycles += cyclesSpent
        PC += 2

        return address
    }
}
