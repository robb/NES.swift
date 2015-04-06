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

/// `BRK` - Force Interrupt
public func BRK(var cpu: CPU) -> CPU {
    cpu.push16(cpu.PC)
    cpu.push(cpu.P)
    cpu.breakCommand = true
    cpu.PC = cpu.memory.read16(0xFFFE)

    return cpu
}

/// `EOR` - Logical Exclusive OR
public func EOR(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(cpu.A ^ value)

    return cpu
}

/// `LDA` - Load Accumulator
public func LDA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(value)

    return cpu
}

/// `ORA` - Logical Inclusive OR
public func ORA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.updateAZN(cpu.A | value)

    return cpu
}

/// `PHP` - Push Processor Status
public func PHP(var cpu: CPU) -> CPU {
    cpu.push(cpu.P)

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
