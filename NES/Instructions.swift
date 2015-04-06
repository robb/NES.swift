import Foundation

/// `ADC` - Add with Carry
public func ADC(var cpu: CPU, value: UInt8) -> CPU {
    let a: UInt8 = cpu.A
    let b: UInt8 = value
    let c: UInt8 = cpu.carryFlag ? 1 : 0

    cpu.AZN = a &+ b &+ c

    cpu.carryFlag = UInt16(a) + UInt16(b) + UInt16(c) > 0xFF
    cpu.overflowFlag = (a ^ b) & 0x80 == 0 && (a ^ cpu.A) & 0x80 != 0

    return cpu
}

/// `AND` - Logical AND
public func AND(var cpu: CPU, value: UInt8) -> CPU {
    cpu.AZN = cpu.A & value

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
    cpu.AZN = cpu.A ^ value

    return cpu
}

/// `LDA` - Load Accumulator
public func LDA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.AZN = value

    return cpu
}

/// `ORA` - Logical Inclusive OR
public func ORA(var cpu: CPU, value: UInt8) -> CPU {
    cpu.AZN = cpu.A | value

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
