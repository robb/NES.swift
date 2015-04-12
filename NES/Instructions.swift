import Foundation

public extension CPU {
    /// `ADC` - Add with Carry
    public mutating func ADC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = C ? 1 : 0

        updateAZN(a &+ b &+ c)

        C = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
        V = (a ^ b) & 0x80 == 0 && (a ^ A) & 0x80 != 0
    }

    /// `AND` - Logical AND
    public mutating func AND(value: UInt8) {
        updateAZN(A & value)
    }

    /// `ASL` - Arithmetic Shift Left
    public mutating func ASL() {
        C = (A & 0x80) != 0
        updateAZN(A << 1)
    }

    /// `ASL` - Arithmetic Shift Left
    public mutating func ASL(address: Address) {
        let value = memory.read(address)
        C = (value & 0x80) != 0

        let result = value << 1
        updateZN(result)
        memory.write(address, result)
    }

    private mutating func branch(offset: UInt8) {
        let address: Address

        if (offset & 0x80) == 0 {
            address = PC &+ UInt16(offset)
        } else {
            address = PC &+ UInt16(offset) &- 0x0100
        }

        cycles += differentPages(PC, address) ? 2 : 1
        PC = address
    }

    /// `BCC` - Branch if Carry Clear
    public mutating func BCC(offset: UInt8) {
        if !C {
            branch(offset)
        }
    }

    /// `BCS` - Branch if Carry Set
    public mutating func BCS(offset: UInt8) {
        if C {
            branch(offset)
        }
    }

    /// `BEQ` - Branch if Equal
    public mutating func BEQ(offset: UInt8) {
        if Z {
            branch(offset)
        }
    }

    /// `BIT` - Bit Test
    public mutating func BIT(address: UInt16) {
        let value = memory.read(address)

        Z = (A & value) == 0
        V = (0x40 & value) != 0
        N = (0x80 & value) != 0
    }

    /// `BMI` - Branch if Minus
    public mutating func BMI(offset: UInt8) {
        if N {
            branch(offset)
        }
    }

    /// `BNE` - Branch if Not Equal
    public mutating func BNE(offset: UInt8) {
        if !Z {
            branch(offset)
        }
    }

    /// `BPL` - Branch if Positive
    public mutating func BPL(offset: UInt8) {
        if !N {
            branch(offset)
        }
    }

    /// `BRK` - Force Interrupt
    public mutating func BRK() {
        push16(PC)
        push(P)
        B = true
        PC = memory.read16(0xFFFE)
    }

    /// `BVC` - Branch if Overflow Clear
    public mutating func BVC(offset: UInt8) {
        if !V {
            branch(offset)
        }
    }

    /// `BVS` - Branch if Overflow Clear
    public mutating func BVS(offset: UInt8) {
        if V {
            branch(offset)
        }
    }

    /// `CLC` - Clear Carry Flag
    public mutating func CLC() {
        C = false
    }

    /// `CLD` - Clear Decimal Mode
    public mutating func CLD() {
        D = false
    }

    /// `CLI` - Clear Interrupt Disable
    public mutating func CLI() {
        I = false
    }

    /// `CLV` - Clear Overflow Flag
    public mutating func CLV() {
        V = false
    }

    private mutating func compare(a: UInt8, _ b: UInt8) {
        updateZN(a &- b)
        C = a >= b
    }

    /// `CMP` - Compare
    public mutating func CMP(value: UInt8) {
        compare(A, value)
    }

    /// `CPX` - Compare X Register
    public mutating func CPX(value: UInt8) {
        compare(X, value)
    }

    /// `CPY` - Compare Y Register
    public mutating func CPY(value: UInt8) {
        compare(Y, value)
    }

    /// `DEC` - Increment Memory
    public mutating func DEC(address: Address) {
        let result = memory.read(address) &- 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `DEX` - Decrement X Register
    public mutating func DEX() {
        X = X &- 1
        updateZN(X)
    }

    /// `DEY` - Decrement Y Register
    public mutating func DEY() {
        Y = Y &- 1
        updateZN(Y)
    }

    /// `EOR` - Logical Exclusive OR
    public mutating func EOR(value: UInt8) {
        updateAZN(A ^ value)
    }

    /// `INC` - Increment Memory
    public mutating func INC(address: Address) {
        let result = memory.read(address) &+ 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `INX` - Increment X Register
    public mutating func INX() {
        X = X &+ 1
        updateZN(X)
    }

    /// `INY` - Increment Y Register
    public mutating func INY() {
        Y = Y &+ 1
        updateZN(Y)
    }

    /// `JMP` - Jump
    public mutating func JMP(address: Address) {
        PC = address
    }

    /// `JSR` - Jump to Subroutine
    public mutating func JSR(address: Address) {
        push16(PC - 1)
        PC = address
    }

    /// `LDA` - Load Accumulator
    public mutating func LDA(value: UInt8) {
        updateAZN(value)
    }

    /// `LDX` - Load X Register
    public mutating func LDX(value: UInt8) {
        X = value
        updateZN(value)
    }

    /// `LDY` - Load Y Register
    public mutating func LDY(value: UInt8) {
        Y = value
        updateZN(value)
    }

    /// `LSR` - Logical Shift Right
    public mutating func LSR() {
        C = (A & 0x01) != 0
        updateAZN(A >> 1)
    }

    /// `LSR` - Logical Shift Right
    public mutating func LSR(address: Address) {
        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = value >> 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `NOP` - No Operation
    public mutating func NOP(cpu: CPU) {
    }

    /// `ORA` - Logical Inclusive OR
    public mutating func ORA(value: UInt8) {
        updateAZN(A | value)
    }

    /// `PHA` - Push Accumulator
    public mutating func PHA() {
        push(A)
    }

    /// `PHP` - Push Processor Status
    public mutating func PHP() {
        push(P)
    }

    /// `PLA` - Pull Accumulator
    public mutating func PLA() {
        A = pop()
    }

    /// `PLP` - Pull Processor Status
    public mutating func PLP() {
        P = pop()
    }

    /// `ROL` - Rotate Left
    public mutating func ROL() {
        let existing: UInt8 = C ? 0x01 : 0x00

        C = (A & 0x80) != 0
        updateAZN((A << 1) | existing)
    }

    /// `ROL` - Rotate Left
    public mutating func ROL(address: Address) {
        let existing: UInt8 = C ? 0x01 : 0x00

        let value = memory.read(address)
        C = (value & 0x80) != 0

        let result = (value << 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `ROR` - Rotate Right
    public mutating func ROR() {
        let existing: UInt8 = C ? 0x80 : 0x00

        C = (A & 0x01) != 0
        updateAZN((A >> 1) | existing)
    }

    /// `ROR` - Rotate Right
    public mutating func ROR(address: Address) {
        let existing: UInt8 = C ? 0x80 : 0x00

        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = (value >> 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `SEI` - Set Interrupt Disable
    public mutating func SEI() {
        I = true
    }

    /// `STA` - Store accumulator
    public mutating func STA(address: Address) {
        memory.write(address, A)
    }

    /// `STX` - Store X register
    public mutating func STX(address: Address) {
        memory.write(address, X)
    }

    /// `STY` - Store Y register
    public mutating func STY(address: Address) {
        memory.write(address, Y)
    }

    /// `TAX` - Transfer Accumulator to X
    public mutating func TAX() {
        X = A
        updateZN(X)
    }

    /// `TAY` - Transfer Accumulator to Y
    public mutating func TAY() {
        Y = A
        updateZN(Y)
    }
}
