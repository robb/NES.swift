import Foundation
import Prelude

private func differentPages(a: UInt16, b: UInt16) -> Bool {
    return (a & 0xFF00) != (b & 0xFF00)
}

public func absolute(instruction: (CPU, UInt16) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let address = cpu.memory.read16(cpu.PC + 1)

    cpu.cycles += cycles
    cpu.PC += 3

    return instruction(cpu, address)
}

public func absoluteX(instruction: (CPU, UInt16) -> CPU, # cycles: UInt64, pageBoundaryCost: UInt64 = 0)(var cpu: CPU) -> CPU {
    let address = cpu.memory.read16(cpu.PC + 1) + UInt16(cpu.X)

    cpu.PC += 3
    cpu.cycles += cycles

    if differentPages(address, address - UInt16(cpu.X)) {
        cpu.cycles += pageBoundaryCost
    }

    return instruction(cpu, address)
}

public func absoluteY(instruction: (CPU, UInt16) -> CPU, # cycles: UInt64, pageBoundaryCost: UInt64 = 0)(var cpu: CPU) -> CPU {
    let address = cpu.memory.read16(cpu.PC + 1) + UInt16(cpu.Y)

    cpu.cycles += cycles
    cpu.PC += 3

    if differentPages(address, address &- UInt16(cpu.Y)) {
        cpu.cycles += pageBoundaryCost
    }

    return instruction(cpu, address)
}

public func accumulator(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, cpu.A)
}

public func immediate(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let operand = cpu.memory.read(cpu.PC + 1)

    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, operand)
}

public func implicied(instruction: CPU -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    cpu.cycles += cycles
    cpu.PC += 1

    return instruction(cpu)
}

public func indexedIndirect(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let address = UInt16(cpu.memory.read(cpu.PC + 1) &+ cpu.X)
    let operand = cpu.memory.read(address)

    cpu.cycles += cycles
    cpu.PC += 3

    return instruction(cpu, operand)
}

public func indirect(instruction: (CPU, UInt16) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let address = cpu.memory.read16(cpu.PC + 1)
    let operand = cpu.memory.read16(address)

    cpu.cycles += cycles
    cpu.PC += 3

    return instruction(cpu, address)
}

public func indirectIndexed(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64, pageBoundaryCost: UInt64 = 0)(var cpu: CPU) -> CPU {
    let address = UInt16(cpu.memory.read(cpu.PC + 1)) &+ UInt16(cpu.Y)
    let operand = cpu.memory.read(address)

    cpu.cycles += cycles
    cpu.PC += 3

    if differentPages(address, address &- UInt16(cpu.Y)) {
        cpu.cycles += pageBoundaryCost
    }

    return instruction(cpu, operand)
}

public func relative(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    var offset = cpu.memory.read(cpu.PC + 1)

    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, offset)
}

public func zeroPage(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let operand = cpu.memory.read(cpu.PC + 1)

    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, operand)
}

public func zeroPageX(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let operand = cpu.memory.read(cpu.PC + 1) &+ cpu.X

    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, operand)
}

public func zeroPageY(instruction: (CPU, UInt8) -> CPU, # cycles: UInt64)(var cpu: CPU) -> CPU {
    let operand = cpu.memory.read(cpu.PC + 1) &+ cpu.Y

    cpu.cycles += cycles
    cpu.PC += 2

    return instruction(cpu, operand)
}
