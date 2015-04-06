import Foundation

/// `ADC` - Add with Carry
public func ADC(var cpu: CPU, value: UInt8) -> CPU {
    let a: UInt8 = cpu.A
    let b: UInt8 = value
    let c: UInt8 = cpu.carryFlag ? 1 : 0

    cpu.updateAZN(a &+ b &+ c)

    cpu.carryFlag = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
    cpu.overflowFlag = (a ^ b) & 0x80 == 0 && (a ^ cpu.A) & 0x80 != 0

    return cpu
}

/// `AND` - Logical AND
public func AND(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(cpu.A & value)

    return cpu
}

/// `ASL` - Arithmetic Shift Left
public func ASL(var cpu: CPU) -> CPU {
    cpu.carryFlag = (cpu.A & 0x80) != 0
    cpu.updateAZN(cpu.A << 1)

    return cpu
}

/// `ASL` - Arithmetic Shift Left
public func ASL(var cpu: CPU, address: Address) -> CPU {
    let value = cpu.memory.read(address)
    cpu.carryFlag = (value & 0x80) != 0

    let result = value << 1
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

private func branch(var cpu: CPU, offset: UInt8) -> CPU {
    let address: Address

    if (offset & 0x80) == 0 {
        address = cpu.PC &+ UInt16(offset)
    } else {
        address = cpu.PC &+ UInt16(offset) &- 0x0100
    }

    cpu.cycles += differentPages(cpu.PC, address) ? 2 : 1
    cpu.PC = address

    return cpu
}

/// `BCC` - Branch if Carry Clear
public func BCC(var cpu: CPU, offset: UInt8) -> CPU {
    return !cpu.carryFlag ? branch(cpu, offset) : cpu
}

/// `BCS` - Branch if Carry Set
public func BCS(var cpu: CPU, offset: UInt8) -> CPU {
    return cpu.carryFlag ? branch(cpu, offset) : cpu
}

/// `BEQ` - Branch if Equal
public func BEQ(var cpu: CPU, offset: UInt8) -> CPU {
    return cpu.zeroFlag ? branch(cpu, offset) : cpu
}

/// `BMI` - Branch if Minus
public func BMI(var cpu: CPU, offset: UInt8) -> CPU {
    return cpu.negativeFlag ? branch(cpu, offset) : cpu
}

/// `BNE` - Branch if Not Equal
public func BNE(var cpu: CPU, offset: UInt8) -> CPU {
    return !cpu.zeroFlag ? branch(cpu, offset) : cpu
}

/// `BPL` - Branch if Positive
public func BPL(var cpu: CPU, offset: UInt8) -> CPU {
    return !cpu.negativeFlag ? branch(cpu, offset) : cpu
}

/// `BRK` - Force Interrupt
public func BRK(var cpu: CPU) -> CPU {
    cpu.push16(cpu.PC)
    cpu.push(cpu.P)
    cpu.breakCommand = true
    cpu.PC = cpu.memory.read16(0xFFFE)

    return cpu
}

/// `BVC` - Branch if Overflow Clear
public func BVC(var cpu: CPU, offset: UInt8) -> CPU {
    return !cpu.overflowFlag ? branch(cpu, offset) : cpu
}

/// `BVS` - Branch if Overflow Clear
public func BVS(var cpu: CPU, offset: UInt8) -> CPU {
    return cpu.overflowFlag ? branch(cpu, offset) : cpu
}

/// `DEC` - Increment Memory
public func DEC(var cpu: CPU, address: Address) -> CPU {
    let result = cpu.memory.read(address) &- 1
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

/// `EOR` - Logical Exclusive OR
public func EOR(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(cpu.A ^ value)

    return cpu
}

/// `INC` - Increment Memory
public func INC(var cpu: CPU, address: Address) -> CPU {
    let result = cpu.memory.read(address) &+ 1
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

/// `LDA` - Load Accumulator
public func LDA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(value)

    return cpu
}

/// `LSR` - Logical Shift Right
public func LSR(var cpu: CPU) -> CPU {
    cpu.carryFlag = (cpu.A & 0x01) != 0
    cpu.updateAZN(cpu.A >> 1)

    return cpu
}

/// `LSR` - Logical Shift Right
public func LSR(var cpu: CPU, address: Address) -> CPU {
    let value = cpu.memory.read(address)
    cpu.carryFlag = (value & 0x01) != 0

    let result = value >> 1
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

/// `NOP` - No Operation
public func NOP(cpu: CPU) -> CPU {
    return cpu
}

/// `ORA` - Logical Inclusive OR
public func ORA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(cpu.A | value)

    return cpu
}

/// `PHA` - Push Accumulator
public func PHA(var cpu: CPU) -> CPU {
    cpu.push(cpu.A)

    return cpu
}

/// `PHP` - Push Processor Status
public func PHP(var cpu: CPU) -> CPU {
    cpu.push(cpu.P)

    return cpu
}

/// `PLA` - Pull Accumulator
public func PLA(var cpu: CPU) -> CPU {
    cpu.A = cpu.pop()

    return cpu
}

/// `PLP` - Pull Processor Status
public func PLP(var cpu: CPU) -> CPU {
    cpu.P = cpu.pop()

    return cpu
}

/// `ROL` - Rotate Left
public func ROL(var cpu: CPU) -> CPU {
    let existing: UInt8 = cpu.carryFlag ? 0x01 : 0x00

    cpu.carryFlag = (cpu.A & 0x80) != 0
    cpu.updateAZN((cpu.A << 1) | existing)

    return cpu
}

/// `ROL` - Rotate Left
public func ROL(var cpu: CPU, address: Address) -> CPU {
    let existing: UInt8 = cpu.carryFlag ? 0x01 : 0x00

    let value = cpu.memory.read(address)
    cpu.carryFlag = (value & 0x80) != 0

    let result = (value << 1) | existing
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

/// `ROR` - Rotate Right
public func ROR(var cpu: CPU) -> CPU {
    let existing: UInt8 = cpu.carryFlag ? 0x80 : 0x00

    cpu.carryFlag = (cpu.A & 0x01) != 0
    cpu.updateAZN((cpu.A >> 1) | existing)

    return cpu
}

/// `ROR` - Rotate Right
public func ROR(var cpu: CPU, address: Address) -> CPU {
    let existing: UInt8 = cpu.carryFlag ? 0x80 : 0x00

    let value = cpu.memory.read(address)
    cpu.carryFlag = (value & 0x01) != 0

    let result = (value >> 1) | existing
    cpu.updateZN(result)
    cpu.memory.write(address, result)

    return cpu
}

/// `SEI` - Set Interrupt Disable
public func SEI(var cpu: CPU) -> CPU {
    cpu.interruptDisable = true

    return cpu
}

/// `STA` - Store accumulator
public func STA(var cpu: CPU, address: Address) -> CPU {
    cpu.memory.write(address, cpu.A)

    return cpu
}

/// `STX` - Store X register
public func STX(var cpu: CPU, address: Address) -> CPU {
    cpu.memory.write(address, cpu.X)

    return cpu
}

/// `STY` - Store Y register
public func STY(var cpu: CPU, address: Address) -> CPU {
    cpu.memory.write(address, cpu.Y)

    return cpu
}

/// `TAX` - Transfer Accumulator to X
public func TAX(var cpu: CPU) -> CPU {
    cpu.X = cpu.A
    cpu.updateZN(cpu.X)

    return cpu
}

/// `TAY` - Transfer Accumulator to Y
public func TAY(var cpu: CPU) -> CPU {
    cpu.Y = cpu.A
    cpu.updateZN(cpu.Y)

    return cpu
}
