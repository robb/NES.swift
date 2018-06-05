import Foundation

internal extension CPU {
    /// `ADC` - Add with Carry
    func adc(_ value: UInt8) {
        let accumulator = a
        let carry: UInt8 = c ? 0x01 : 0x00

        updateAZN(accumulator &+ value &+ carry)

        c = UInt16(accumulator) + UInt16(value) + UInt16(carry) > 0x00FF
        v = (accumulator ^ value) & 0x80 == 0 && (accumulator ^ a) & 0x80 != 0
    }

    /// `AND` - Logical AND
    func and(_ value: UInt8) {
        updateAZN(a & value)
    }

    /// `ASL` - Arithmetic Shift Left
    func asl() {
        c = (a & 0x80) != 0
        updateAZN(a << 1)
    }

    /// `ASL` - Arithmetic Shift Left
    func asl(_ address: Address) {
        let value = read(address)
        c = (value & 0x80) != 0

        let result = value << 1
        updateZN(result)
        write(address, result)
    }

    private func branch(_ offset: UInt8) {
        let address: Address

        if (offset & 0x80) == 0 {
            address = pc &+ UInt16(offset)
        } else {
            address = pc &+ UInt16(offset) &- 0x0100
        }

        cycles += differentPages(pc, address) ? 2 : 1
        pc = address
    }

    /// `BCC` - Branch if Carry Clear
    func bcc(_ offset: UInt8) {
        if !c {
            branch(offset)
        }
    }

    /// `BCS` - Branch if Carry Set
    func bcs(_ offset: UInt8) {
        if c {
            branch(offset)
        }
    }

    /// `BEQ` - Branch if Equal
    func beq(_ offset: UInt8) {
        if z {
            branch(offset)
        }
    }

    /// `BIT` - Bit Test
    func bit(_ address: Address) {
        let value = read(address)

        z = (a & value) == 0
        v = (0x40 & value) != 0
        n = (0x80 & value) != 0
    }

    /// `BMI` - Branch if Minus
    func bmi(_ offset: UInt8) {
        if n {
            branch(offset)
        }
    }

    /// `BNE` - Branch if Not Equal
    func bne(_ offset: UInt8) {
        if !z {
            branch(offset)
        }
    }

    /// `BPL` - Branch if Positive
    func bpl(_ offset: UInt8) {
        if !n {
            branch(offset)
        }
    }

    /// `BRK` - Force Interrupt
    func brk() {
        push16(pc)
        push(p)
        b = true
        pc = read16(CPU.irqInterruptVector)
    }

    /// `BVC` - Branch if Overflow Clear
    func bvc(_ offset: UInt8) {
        if !v {
            branch(offset)
        }
    }

    /// `BVS` - Branch if Overflow Clear
    func bvs(_ offset: UInt8) {
        if v {
            branch(offset)
        }
    }

    /// `CLC` - Clear Carry Flag
    func clc() {
        c = false
    }

    /// `CLD` - Clear Decimal Mode
    func cld() {
        d = false
    }

    /// `CLI` - Clear Interrupt Disable
    func cli() {
        i = false
    }

    /// `CLV` - Clear Overflow Flag
    func clv() {
        v = false
    }

    private func compare(_ a: UInt8, _ b: UInt8) {
        updateZN(a &- b)
        c = a >= b
    }

    /// `CMP` - Compare
    func cmp(_ value: UInt8) {
        compare(a, value)
    }

    /// `CPX` - Compare X Register
    func cpx(_ value: UInt8) {
        compare(x, value)
    }

    /// `CPY` - Compare Y Register
    func cpy(_ value: UInt8) {
        compare(y, value)
    }

    /// `DEC` - Increment Memory
    func dec(_ address: Address) {
        let result = read(address) &- 1
        updateZN(result)
        write(address, result)
    }

    /// `DEX` - Decrement X Register
    func dex() {
        x = x &- 1
        updateZN(x)
    }

    /// `DEY` - Decrement Y Register
    func dey() {
        y = y &- 1
        updateZN(y)
    }

    /// `EOR` - Logical Exclusive OR
    func eor(_ value: UInt8) {
        updateAZN(a ^ value)
    }

    /// `INC` - Increment Memory
    func inc(_ address: Address) {
        let result = read(address) &+ 1
        updateZN(result)
        write(address, result)
    }

    /// `INX` - Increment X Register
    func inx() {
        x = x &+ 1
        updateZN(x)
    }

    /// `INY` - Increment Y Register
    func iny() {
        y = y &+ 1
        updateZN(y)
    }

    /// `JMP` - Jump
    func jmp(_ address: Address) {
        pc = address
    }

    /// `JSR` - Jump to Subroutine
    func jsr(_ address: Address) {
        push16(pc - 1)
        pc = address
    }

    /// `LDA` - Load Accumulator
    func lda(_ value: UInt8) {
        updateAZN(value)
    }

    /// `LDX` - Load X Register
    func ldx(_ value: UInt8) {
        x = value
        updateZN(value)
    }

    /// `LDY` - Load Y Register
    func ldy(_ value: UInt8) {
        y = value
        updateZN(value)
    }

    /// `LSR` - Logical Shift Right
    func lsr() {
        c = (a & 0x01) != 0
        updateAZN(a >> 1)
    }

    /// `LSR` - Logical Shift Right
    func lsr(_ address: Address) {
        let value = read(address)
        c = (value & 0x01) != 0

        let result = value >> 1
        updateZN(result)
        write(address, result)
    }

    /// `NOP` - No Operation
    func nop() {
    }

    /// `ORA` - Logical Inclusive OR
    func ora(_ value: UInt8) {
        updateAZN(a | value)
    }

    /// `PHA` - Push Accumulator
    func pha() {
        push(a)
    }

    /// `PHP` - Push Processor Status
    func php() {
        push(p | 0x10)
    }

    /// `PLA` - Pull Accumulator
    func pla() {
        updateAZN(pop())
    }

    /// `PLP` - Pull Processor Status
    func plp() {
        p = pop() & 0xEF | 0x20
    }

    /// `ROL` - Rotate Left
    func rol() {
        let existing: UInt8 = c ? 0x01 : 0x00

        c = (a & 0x80) != 0
        updateAZN((a << 1) | existing)
    }

    /// `ROL` - Rotate Left
    func rol(_ address: Address) {
        let existing: UInt8 = c ? 0x01 : 0x00

        let value = read(address)
        c = (value & 0x80) != 0

        let result = (value << 1) | existing
        updateZN(result)
        write(address, result)
    }

    /// `ROR` - Rotate Right
    func ror() {
        let existing: UInt8 = c ? 0x80 : 0x00

        c = (a & 0x01) != 0
        updateAZN((a >> 1) | existing)
    }

    /// `ROR` - Rotate Right
    func ror(_ address: Address) {
        let existing: UInt8 = c ? 0x80 : 0x00

        let value = read(address)
        c = (value & 0x01) != 0

        let result = (value >> 1) | existing
        updateZN(result)
        write(address, result)
    }

    /// `RTI` - Return from Interrupt
    func rti() {
        p = pop() & 0xEF | 0x20
        pc = pop16()
    }

    /// `RTS` - Return from Subroutine
    func rts() {
        pc = pop16() &+ 1
    }

    /// `SBC` - Subtract with Carry
    func sbc(_ value: UInt8) {
        let accumulator = a
        let carry: UInt8 = c ? 0x01 : 0x00

        updateAZN(accumulator &- value &- (1 - carry))

        c = Int16(accumulator) - Int16(value) - Int16(1 - carry) >= 0
        v = (accumulator ^ value) & 0x80 != 0 && (accumulator ^ a) & 0x80 != 0
    }

    /// `SEI` - Set Interrupt Disable
    func sei() {
        i = true
    }

    /// `SEC` - Set Carry Flag
    func sec() {
        c = true
    }

    /// `SED` - Set Decimal Flag
    func sed() {
        d = true
    }

    /// `STA` - Store accumulator
    func sta(_ address: Address) {
        write(address, a)
    }

    /// `STX` - Store X register
    func stx(_ address: Address) {
        write(address, x)
    }

    /// `STY` - Store Y register
    func sty(_ address: Address) {
        write(address, y)
    }

    /// `TAX` - Transfer Accumulator to X
    func tax() {
        x = a
        updateZN(x)
    }

    /// `TAY` - Transfer Accumulator to Y
    func tay() {
        y = a
        updateZN(y)
    }

    /// `TSX` - Transfer Stack Pointer to X
    func tsx() {
        x = sp
        updateZN(x)
    }

    /// `TXA` - Transfer X to Accumulator
    func txa() {
        updateAZN(x)
    }

    /// `TXS` - Transfer X to Stack Pointer
    func txs() {
        sp = x
    }

    /// `TYA` - Transfer Y to Accumulator
    func tya() {
        updateAZN(y)
    }
}

extension CPU {
    /// `DCP` - ???
    func dcp(_ address: Address) {
        let value = read(address) &- 1
        write(address, value)
        cmp(value)
    }

    /// `DOP` - Double NOP
    func dop(_: UInt8) { }

    /// `ISC` - ???
    func isc(_ address: Address) {
        inc(address)
        sbc(read(address))
    }

    /// `LAX` - ???
    func lax(_ address: Address) {
        let value = read(address)
        a = value
        x = value
        updateZN(value)
    }

    /// `SAX` - ???
    func sax(_ address: Address) {
        write(address, a & x)
    }

    /// `SLO` - ???
    func slo(_ address: Address) {
        asl(address)
        ora(read(address))
    }

    /// `SRE` - ???
    func sre(_ address: Address) {
        lsr(address)
        eor(read(address))
    }

    /// `RLA` - ???
    func rla(_ address: Address) {
        rol(address)
        and(read(address))
    }

    /// `RRA` - ???
    func rra(_ address: Address) {
        ror(address)
        adc(read(address))
    }

    /// `TOP` - Triple NOP
    func top(_: UInt16) { }
}
