import Foundation

internal extension CPU {
    /// `ADC` - Add with Carry
    func ADC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = C ? 1 : 0

        updateAZN(a &+ b &+ c)

        C = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
        V = (a ^ b) & 0x80 == 0 && (a ^ A) & 0x80 != 0
    }

    /// `AND` - Logical AND
    func AND(value: UInt8) {
        updateAZN(A & value)
    }

    /// `ASL` - Arithmetic Shift Left
    func ASL() {
        C = (A & 0x80) != 0
        updateAZN(A << 1)
    }

    /// `ASL` - Arithmetic Shift Left
    func ASL(address: Address) {
        let value = memory.read(address)
        C = (value & 0x80) != 0

        let result = value << 1
        updateZN(result)
        memory.write(address, result)
    }

    private func branch(offset: UInt8) {
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
    func BCC(offset: UInt8) {
        if !C {
            branch(offset)
        }
    }

    /// `BCS` - Branch if Carry Set
    func BCS(offset: UInt8) {
        if C {
            branch(offset)
        }
    }

    /// `BEQ` - Branch if Equal
    func BEQ(offset: UInt8) {
        if Z {
            branch(offset)
        }
    }

    /// `BIT` - Bit Test
    func BIT(address: Address) {
        let value = memory.read(address)

        Z = (A & value) == 0
        V = (0x40 & value) != 0
        N = (0x80 & value) != 0
    }

    /// `BMI` - Branch if Minus
    func BMI(offset: UInt8) {
        if N {
            branch(offset)
        }
    }

    /// `BNE` - Branch if Not Equal
    func BNE(offset: UInt8) {
        if !Z {
            branch(offset)
        }
    }

    /// `BPL` - Branch if Positive
    func BPL(offset: UInt8) {
        if !N {
            branch(offset)
        }
    }

    /// `BRK` - Force Interrupt
    func BRK() {
        push16(PC)
        push(P)
        B = true
        PC = memory.read16(CPU.IRQInterruptVector)
    }

    /// `BVC` - Branch if Overflow Clear
    func BVC(offset: UInt8) {
        if !V {
            branch(offset)
        }
    }

    /// `BVS` - Branch if Overflow Clear
    func BVS(offset: UInt8) {
        if V {
            branch(offset)
        }
    }

    /// `CLC` - Clear Carry Flag
    func CLC() {
        C = false
    }

    /// `CLD` - Clear Decimal Mode
    func CLD() {
        D = false
    }

    /// `CLI` - Clear Interrupt Disable
    func CLI() {
        I = false
    }

    /// `CLV` - Clear Overflow Flag
    func CLV() {
        V = false
    }

    private func compare(a: UInt8, _ b: UInt8) {
        updateZN(a &- b)
        C = a >= b
    }

    /// `CMP` - Compare
    func CMP(value: UInt8) {
        compare(A, value)
    }

    /// `CPX` - Compare X Register
    func CPX(value: UInt8) {
        compare(X, value)
    }

    /// `CPY` - Compare Y Register
    func CPY(value: UInt8) {
        compare(Y, value)
    }

    /// `DEC` - Increment Memory
    func DEC(address: Address) {
        let result = memory.read(address) &- 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `DEX` - Decrement X Register
    func DEX() {
        X = X &- 1
        updateZN(X)
    }

    /// `DEY` - Decrement Y Register
    func DEY() {
        Y = Y &- 1
        updateZN(Y)
    }

    /// `EOR` - Logical Exclusive OR
    func EOR(value: UInt8) {
        updateAZN(A ^ value)
    }

    /// `INC` - Increment Memory
    func INC(address: Address) {
        let result = memory.read(address) &+ 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `INX` - Increment X Register
    func INX() {
        X = X &+ 1
        updateZN(X)
    }

    /// `INY` - Increment Y Register
    func INY() {
        Y = Y &+ 1
        updateZN(Y)
    }

    /// `JMP` - Jump
    func JMP(address: Address) {
        PC = address
    }

    /// `JSR` - Jump to Subroutine
    func JSR(address: Address) {
        push16(PC - 1)
        PC = address
    }

    /// `LDA` - Load Accumulator
    func LDA(value: UInt8) {
        updateAZN(value)
    }

    /// `LDX` - Load X Register
    func LDX(value: UInt8) {
        X = value
        updateZN(value)
    }

    /// `LDY` - Load Y Register
    func LDY(value: UInt8) {
        Y = value
        updateZN(value)
    }

    /// `LSR` - Logical Shift Right
    func LSR() {
        C = (A & 0x01) != 0
        updateAZN(A >> 1)
    }

    /// `LSR` - Logical Shift Right
    func LSR(address: Address) {
        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = value >> 1
        updateZN(result)
        memory.write(address, result)
    }

    /// `NOP` - No Operation
    func NOP() {
    }

    /// `ORA` - Logical Inclusive OR
    func ORA(value: UInt8) {
        updateAZN(A | value)
    }

    /// `PHA` - Push Accumulator
    func PHA() {
        push(A)
    }

    /// `PHP` - Push Processor Status
    func PHP() {
        push(P | 0x10)
    }

    /// `PLA` - Pull Accumulator
    func PLA() {
        updateAZN(pop())
    }

    /// `PLP` - Pull Processor Status
    func PLP() {
        P = pop() & 0xEF | 0x20
    }

    /// `ROL` - Rotate Left
    func ROL() {
        let existing: UInt8 = C ? 0x01 : 0x00

        C = (A & 0x80) != 0
        updateAZN((A << 1) | existing)
    }

    /// `ROL` - Rotate Left
    func ROL(address: Address) {
        let existing: UInt8 = C ? 0x01 : 0x00

        let value = memory.read(address)
        C = (value & 0x80) != 0

        let result = (value << 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `ROR` - Rotate Right
    func ROR() {
        let existing: UInt8 = C ? 0x80 : 0x00

        C = (A & 0x01) != 0
        updateAZN((A >> 1) | existing)
    }

    /// `RTI` - Return from Interrupt
    func RTI() {
        P = pop() & 0xEF | 0x20
        PC = pop16()
    }

    /// `RTS` - Return from Subroutine
    func RTS() {
        PC = pop16() + 1
    }

    /// `ROR` - Rotate Right
    func ROR(address: Address) {
        let existing: UInt8 = C ? 0x80 : 0x00

        let value = memory.read(address)
        C = (value & 0x01) != 0

        let result = (value >> 1) | existing
        updateZN(result)
        memory.write(address, result)
    }

    /// `SBC` - Subtract with Carry
    func SBC(value: UInt8) {
        let a: UInt8 = A
        let b: UInt8 = value
        let c: UInt8 = C ? 1 : 0

        updateAZN(a &- b &- (1 - c))

        C = Int16(a) - Int16(b) - Int16(1 - c) >= 0
        V = (a ^ b) & 0x80 != 0 && (a ^ A) & 0x80 != 0
    }

    /// `SEI` - Set Interrupt Disable
    func SEI() {
        I = true
    }

    /// `SEC` - Set Carry Flag
    func SEC() {
        C = true
    }

    /// `SED` - Set Decimal Flag
    func SED() {
        D = true
    }

    /// `STA` - Store accumulator
    func STA(address: Address) {
        memory.write(address, A)
    }

    /// `STX` - Store X register
    func STX(address: Address) {
        memory.write(address, X)
    }

    /// `STY` - Store Y register
    func STY(address: Address) {
        memory.write(address, Y)
    }

    /// `TAX` - Transfer Accumulator to X
    func TAX() {
        X = A
        updateZN(X)
    }

    /// `TAY` - Transfer Accumulator to Y
    func TAY() {
        Y = A
        updateZN(Y)
    }

    /// `TSX` - Transfer Stack Pointer to X
    func TSX() {
        X = SP
        updateZN(X)
    }

    /// `TXA` - Transfer X to Accumulator
    func TXA() {
        updateAZN(X)
    }

    /// `TXS` - Transfer X to Stack Pointer
    func TXS() {
        SP = X
    }

    /// `TYA` - Transfer Y to Accumulator
    func TYA() {
        updateAZN(Y)
    }
}

extension CPU {
    /// `DCP` - ???
    func DCP(address: Address) {
        let value = memory.read(address) &- 1
        memory.write(address, value)
        CMP(value)
    }

    /// `DOP` - Double NOP
    func DOP(_: UInt8) { }

    /// `ISC` - ???
    func ISC(address: Address) {
        INC(address)
        SBC(memory.read(address))
    }

    /// `LAX` - ???
    func LAX(address: Address) {
        let value = memory.read(address)
        A = value
        X = value
        updateZN(value)
    }

    /// `SAX` - ???
    func SAX(address: Address) {
        memory.write(address, A & X)
    }

    /// `SLO` - ???
    func SLO(address: Address) {
        ASL(address)
        ORA(memory.read(address))
    }

    /// `SRE` - ???
    func SRE(address: Address) {
        LSR(address)
        EOR(memory.read(address))
    }

    /// `RLA` - ???
    func RLA(address: Address) {
        ROL(address)
        AND(memory.read(address))
    }

    /// `RRA` - ???
    func RRA(address: Address) {
        ROR(address)
        ADC(memory.read(address))
    }

    /// `TOP` - Triple NOP
    func TOP(_: UInt16) { }
}
