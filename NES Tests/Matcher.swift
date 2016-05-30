@testable import NES

import Nimble

func match(state: ConsoleState?) -> Nimble.NonNilMatcherFunc<Console> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        guard let state = state else {
            return false
        }

        guard let console = try actualExpression.evaluate() else {
            return false
        }

        let CPU = console.CPU

        guard CPU.A == state.A else {
            failureMessage.postfixMessage = "have an A register value of \(format(state.A))"
            failureMessage.actualValue = format(CPU.A)

            return false
        }

        guard CPU.X == state.X else {
            failureMessage.postfixMessage = "have an X register value of \(format(state.X))"
            failureMessage.actualValue = format(CPU.X)

            return false
        }

        guard CPU.Y == state.Y else {
            failureMessage.postfixMessage = "have an Y register value of \(format(state.Y))"
            failureMessage.actualValue = format(CPU.Y)

            return false
        }

        guard CPU.P == state.P else {
            failureMessage.postfixMessage = "have an P register value of \(format(state.P))"
            failureMessage.actualValue = format(CPU.P)

            return false
        }

        guard CPU.SP == state.SP else {
            failureMessage.postfixMessage = "have a stack pointer value of \(format(state.SP))"
            failureMessage.actualValue = format(CPU.SP)

            return false
        }

        let PPU = console.PPU

        guard PPU.cycle == state.cycle else {
            failureMessage.postfixMessage = "to be at PPU cycle \(state.cycle)"
            failureMessage.actualValue = "\(PPU.cycle)"

            return false
        }

        guard PPU.scanLine == state.scanLine else {
            failureMessage.postfixMessage = "to be at PPU scan line \(state.scanLine)"
            failureMessage.actualValue = "\(PPU.scanLine)"

            return false
        }

        return true
    }
}
