import Foundation

public extension CPU {
    /// `ADC` - Add with Carry
    public mutating func ADC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = carryFlag ? 1 : 0

        AZN = a &+ b &+ c

        carryFlag = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
        overflowFlag = (a ^ b) & 0x80 == 0 && (a ^ A) & 0x80 != 0
    }

    /// `AND` - Logical AND
    public mutating func AND(value: UInt8) {
        AZN = A & value
    }

    /// `BRK` - Force Interrupt
    public mutating func BRK() {
        push16(PC)
        push(P)
        breakCommand = true
        PC = memory.read16(0xFFFE)
    }

    /// `EOR` - Logical Exclusive OR
    public mutating func EOR(value: UInt8) {
        AZN = A ^ value
    }

    /// `LDA` - Load Accumulator
    public mutating func LDA(value: UInt8) {
        AZN = value
    }

    /// `ORA` - Logical Inclusive OR
    public mutating func ORA(value: UInt8) {
        AZN = A | value
    }

    /// `PHP` - Push Processor Status
    public mutating func PHP() {
        push(P)
    }

    /// `SEI` - Set Interrupt Disable
    public mutating func SEI() {
        interruptDisable = true
    }
}
