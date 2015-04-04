import Foundation

public extension CPU {
    /// `BRK` - Force Interrupt
    public mutating func BRK() {
        push(PC)
        push(P)
        breakCommand = true
        PC = memory[0xFFFE]
    }

    /// `ORA` - Logical Inclusive OR
    public mutating func ORA(address: UInt16) {
        setAZN(A | memory[address])
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
