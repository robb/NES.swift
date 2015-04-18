import Foundation
import Prelude

public extension CPU {
    public mutating func absolute(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1)

        cycles += cyclesSpent
        PC += 3

        instruction(address)
    }

    public mutating func absolute(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 3

        instruction(operand)
    }

    public mutating func absoluteX(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1) &+ Address(X)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        instruction(address)
    }

    public mutating func absoluteX(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1) &+ Address(X)
        let operand = memory.read(address)

        PC += 3
        cycles += cyclesSpent

        if differentPages(address, address &- Address(X)) {
            cycles += pageBoundaryCost
        }

        instruction(operand)
    }

    public mutating func absoluteY(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1) &+ Address(Y)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        instruction(address)
    }

    public mutating func absoluteY(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1) &+ Address(Y)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 3

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        instruction(operand)
    }

    public mutating func accumulator(instruction: Void -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        cycles += cyclesSpent
        PC += 1

        instruction()
    }

    public mutating func immediate(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let operand = memory.read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        instruction(operand)
    }

    public mutating func implied(instruction: Void -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        cycles += cyclesSpent
        PC += 1

        instruction()
    }

    public mutating func indexedIndirect(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1) &+ X)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        instruction(operand)
    }

    public mutating func indexedIndirect(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1) &+ X)

        cycles += cyclesSpent
        PC += 2

        instruction(address)
    }

    public mutating func indirect(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = memory.read16(PC &+ 1)
        let operand = memory.read16(address)

        cycles += cyclesSpent
        PC += 3

        instruction(operand)
    }

    public mutating func indirectIndexed(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1)) &+ Address(Y)
        let operand = memory.read(address)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        instruction(operand)
    }

    public mutating func indirectIndexed(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1)) &+ Address(Y)

        cycles += cyclesSpent
        PC += 2

        if differentPages(address, address &- Address(Y)) {
            cycles += pageBoundaryCost
        }

        instruction(address)
    }

    public mutating func relative(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        var offset = memory.read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        instruction(offset)
    }

    public mutating func zeroPage(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let operand = memory.read(PC &+ 1)

        cycles += cyclesSpent
        PC += 2

        instruction(operand)
    }

    public mutating func zeroPage(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(0, memory.read(PC &+ 1))

        cycles += cyclesSpent
        PC += 2

        instruction(address)
    }

    public mutating func zeroPageX(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let operand = memory.read(PC &+ 1) &+ X

        cycles += cyclesSpent
        PC += 2

        instruction(operand)
    }

    public mutating func zeroPageX(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1) &+ X)

        cycles += cyclesSpent
        PC += 2

        instruction(address)
    }

    public mutating func zeroPageY(instruction: UInt8 -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let operand = memory.read(PC &+ 1) &+ Y

        cycles += cyclesSpent
        PC += 2

        instruction(operand)
    }

    public mutating func zeroPageY(instruction: Address -> Void, cyclesSpent: UInt64, pageBoundaryCost: UInt64) {
        let address = Address(memory.read(PC &+ 1) &+ Y)

        cycles += cyclesSpent
        PC += 2

        instruction(address)
    }
}
