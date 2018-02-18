@testable import NES

import Nimble

func match(state: ConsoleState) -> Predicate<Console?> {
    return Predicate { actual in
        let msg: ExpectationMessage

        guard let value = try actual.evaluate(), let console = value else {
            msg = .expectedTo("match <\(state)>")

            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        }

        let cpu = console.cpu!

        guard cpu.a == state.a else {
            msg = .expectedTo("have an A register value of <\(format(state.a))>, got <\(format(cpu.a))>")

            return PredicateResult(bool: false, message: msg)
        }

        guard cpu.x == state.x else {
            msg = .expectedTo("have an X register value of <\(format(state.x))>, got <\(format(cpu.x))>")

            return PredicateResult(bool: false, message: msg)
        }

        guard cpu.y == state.y else {
            msg = .expectedTo("have a Y register value of <\(format(state.y))>, got <\(format(cpu.y))>")

            return PredicateResult(bool: false, message: msg)
        }

        guard cpu.p == state.p else {
            msg = .expectedTo("have a P register value of <\(format(state.p))>, got <\(format(cpu.p))>")

            return PredicateResult(bool: false, message: msg)
        }

        guard cpu.sp == state.sp else {
            msg = .expectedTo("have a stack pointer value of <\(format(state.sp))>, got <\(format(cpu.sp))>")

            return PredicateResult(bool: false, message: msg)
        }

        let ppu = console.ppu!

        guard ppu.cycle == state.cycle else {
            msg = .expectedTo("be at PPU cycle <\(state.cycle)>, got <\(ppu.cycle)>")

            return PredicateResult(bool: false, message: msg)
        }

        msg = .expectedTo("be at PPU scan line <\(state.scanLine)>, got <\(ppu.scanLine)>")

        return PredicateResult(bool: ppu.scanLine == state.scanLine, message: msg)
    }
}
