import Foundation

public extension CPU {
    /// `AND` - Logical AND
    public mutating func AND(address: UInt16) {
        AZN = A & memory.read(address)
    }

    /// `BRK` - Force Interrupt
    public mutating func BRK() {
        push16(PC)
        push(P)
        breakCommand = true
        PC = memory.read16(0xFFFE)
    }

    /// `ORA` - Logical Inclusive OR
    public mutating func ORA(address: UInt16) {
        AZN = A | memory.read(address)
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
