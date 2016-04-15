import Foundation

internal extension CPU {
    /// `ADC` - Add with Carry
    mutating func ADC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = C ? 1 : 0

        updateAZN(a &+ b &+ c)

        C = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
        V = (a ^ b) & 0x80 == 0 && (a ^ A) & 0x80 != 0
    }

    /// `AND` - Logical AND
    mutating func AND(value: UInt8) {
        updateAZN(A & value)
    }

    /// `ASL` - Arithmetic Shift Left
    mutating func ASL() {
        C = (A & 0x80) != 0
        updateAZN(A << 1)
    }

    /// `ASL` - Arithmetic Shift Left
    mutating func ASL(address: Address) {
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
    mutating func BCC(offset: UInt8) {
        if !C {
            branch(offset)
        }
    }

    /// `BCS` - Branch if Carry Set
    mutating func BCS(offset: UInt8) {
        if C {
            branch(offset)
        }
    }

    /// `BEQ` - Branch if Equal
    mutating func BEQ(offset: UInt8) {
        if Z {
            branch(offset)
        }
    }

    /// `BIT` - Bit Test
    mutating func BIT(address: Address) {
        let value = memory.read(address)

        Z = (A & value) == 0
        V = (0x40 & value) != 0
        N = (0x80 & value) != 0
    }

    /// `BMI` - Branch if Minus
    mutating func BMI(offset: UInt8) {
        if N {
            branch(offset)
        }
    }

    /// `BNE` - Branch if Not Equal
    mutating func BNE(offset: UInt8) {
        if !Z {
            branch(offset)
        }
    }

    /// `BPL` - Branch if Positive
    mutating func BPL(offset: UInt8) {
        if !N {
            branch(offset)
        }
    }

    /// `BRK` - Force Interrupt
    mutating func BRK() {
        push16(PC)
        push(P)
        B = true
        PC = memory.read16(0xFFFE)
    }

    /// `BVC` - Branch if Overflow Clear
    mutating func BVC(offset: UInt8) {
        if !V {
            branch(offset)
        }
    }

    /// `BVS` - Branch if Overflow Clear
    mutating func BVS(offset: UInt8) {
        if V {
            branch(offset)
        }
    }

    /// `CLC` - Clear Carry Flag
    mutating func CLC() {
        C = false
    }

    /// `CLD` - Clear Decimal Mode
    mutating func CLD() {
        D = false
    }

    /// `CLI` - Clear Interrupt Disable
    mutating func CLI() {
        I = false
    }

    /// `CLV` - Clear Overflow Flag
    mutating func CLV() {
        V = false
    }

    private mutating func compare(a: UInt8, _ b: UInt8) {
        updateZN(a &- b)
        C = a >= b
    }

    /// `CMP` - Compare
    mutating func CMP(value: UInt8) {
        compare(A, value)
    }

    /// `CPX` - Compare X Register
    mutating func CPX(value: UInt8) {
        compare(X, value)
    }

    /// `CPY` - Compare Y Register
    mutating func CPY(value: UInt8) {
        compare(Y, value)
    }

    /// `DEC` - Increment Memory
    mutating func DEC(address: Address) {
        let result = memory.read(address) &- 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `DEX` - Decrement X Register
    mutating func DEX() {
        X = X &- 1
        updateZN(X)
    }

    /// `DEY` - Decrement Y Register
    mutating func DEY() {
        Y = Y &- 1
        updateZN(Y)
    }

    /// `EOR` - Logical Exclusive OR
    mutating func EOR(value: UInt8) {
        updateAZN(A ^ value)
    }

    /// `INC` - Increment Memory
    mutating func INC(address: Address) {
        let result = memory.read(address) &+ 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `INX` - Increment X Register
    mutating func INX() {
        X = X &+ 1
        updateZN(X)
    }

    /// `INY` - Increment Y Register
    mutating func INY() {
        Y = Y &+ 1
        updateZN(Y)
    }

    /// `JMP` - Jump
    mutating func JMP(address: Address) {
        PC = address
    }

    /// `JSR` - Jump to Subroutine
    mutating func JSR(address: Address) {
        push16(PC - 1)
        PC = address
    }

    /// `LDA` - Load Accumulator
    mutating func LDA(value: UInt8) {
        updateAZN(value)
    }

    /// `LDX` - Load X Register
    mutating func LDX(value: UInt8) {
        X = value
        updateZN(value)
    }

    /// `LDY` - Load Y Register
    mutating func LDY(value: UInt8) {
        Y = value
        updateZN(value)
    }

    /// `LSR` - Logical Shift Right
    mutating func LSR() {
        C = (A & 0x01) != 0
        updateAZN(A >> 1)
    }

    /// `LSR` - Logical Shift Right
    mutating func LSR(address: Address) {
        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = value >> 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `NOP` - No Operation
    mutating func NOP() {
    }

    /// `ORA` - Logical Inclusive OR
    mutating func ORA(value: UInt8) {
        updateAZN(A | value)
    }

    /// `PHA` - Push Accumulator
    mutating func PHA() {
        push(A)
    }

    /// `PHP` - Push Processor Status
    mutating func PHP() {
        push(P | 0x10)
    }

    /// `PLA` - Pull Accumulator
    mutating func PLA() {
        updateAZN(pop())
    }

    /// `PLP` - Pull Processor Status
    mutating func PLP() {
        P = pop() & 0xEF | 0x20
    }

    /// `ROL` - Rotate Left
    mutating func ROL() {
        let existing: UInt8 = C ? 0x01 : 0x00

        C = (A & 0x80) != 0
        updateAZN((A << 1) | existing)
    }

    /// `ROL` - Rotate Left
    mutating func ROL(address: Address) {
        let existing: UInt8 = C ? 0x01 : 0x00

        let value = memory.read(address)
        C = (value & 0x80) != 0

        let result = (value << 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `ROR` - Rotate Right
    mutating func ROR() {
        let existing: UInt8 = C ? 0x80 : 0x00

        C = (A & 0x01) != 0
        updateAZN((A >> 1) | existing)
    }

    /// `RTI` - Return from Interrupt
    mutating func RTI() {
        P = pop() & 0xEF | 0x20
        PC = pop16()
    }

    /// `RTS` - Return from Subroutine
    mutating func RTS() {
        PC = pop16() + 1
    }

    /// `ROR` - Rotate Right
    mutating func ROR(address: Address) {
        let existing: UInt8 = C ? 0x80 : 0x00

        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = (value >> 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `SBC` - Subtract with Carry
    mutating func SBC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = C ? 1 : 0

        updateAZN(a &- b &- (1 - c))

        C = Int16(a) - Int16(b) - Int16(1 - c) >= 0
        V = (a ^ b) & 0x80 != 0 && (a ^ A) & 0x80 != 0
    }

    /// `SEI` - Set Interrupt Disable
    mutating func SEI() {
        I = true
    }

    /// `SEC` - Set Carry Flag
    mutating func SEC() {
        C = true
    }

    /// `SED` - Set Decimal Flag
    mutating func SED() {
        D = true
    }

    /// `STA` - Store accumulator
    mutating func STA(address: Address) {
        memory.write(address, A)
    }

    /// `STX` - Store X register
    mutating func STX(address: Address) {
        memory.write(address, X)
    }

    /// `STY` - Store Y register
    mutating func STY(address: Address) {
        memory.write(address, Y)
    }

    /// `TAX` - Transfer Accumulator to X
    mutating func TAX() {
        X = A
        updateZN(X)
    }

    /// `TAY` - Transfer Accumulator to Y
    mutating func TAY() {
        Y = A
        updateZN(Y)
    }

    /// `TSX` - Transfer Stack Pointer to X
    mutating func TSX() {
        X = SP
        updateZN(X)
    }

    /// `TXA` - Transfer X to Accumulator
    mutating func TXA() {
        updateAZN(X)
    }

    /// `TXS` - Transfer X to Stack Pointer
    mutating func TXS() {
        SP = X
    }

    /// `TYA` - Transfer Y to Accumulator
    mutating func TYA() {
        updateAZN(Y)
    }
}

extension CPU {
    /// `DCP` - ???
    mutating func DCP(address: Address) {
        let value = memory.read(address) &- 1
        memory.write(address, value)
        CMP(value)
    }

    /// `DOP` - Double NOP
    mutating func DOP(_: UInt8) { }

    /// `ISC` - ???
    mutating func ISC(address: Address) {
        INC(address)
        SBC(memory.read(address))
    }

    /// `LAX` - ???
    mutating func LAX(address: Address) {
        let value = memory.read(address)
        A = value
        X = value
        updateZN(value)
    }

    /// `SAX` - ???
    mutating func SAX(address: Address) {
        memory.write(address, A & X)
    }

    /// `SLO` - ???
    mutating func SLO(address: Address) {
        ASL(address)
        ORA(memory.read(address))
    }

    /// `SRE` - ???
    mutating func SRE(address: Address) {
        LSR(address)
        EOR(memory.read(address))
    }

    /// `RLA` - ???
    mutating func RLA(address: Address) {
        ROL(address)
        AND(memory.read(address))
    }

    /// `RRA` - ???
    mutating func RRA(address: Address) {
        ROR(address)
        ADC(memory.read(address))
    }

    /// `TOP` - Triple NOP
    mutating func TOP(_: UInt16) { }
}
