import Foundation

internal enum Interrupt {
    case None
    case IRQ
    case NMI
}

/// Interrupts.
internal extension CPU {
    static let IRQInterruptVector: Address = 0xFFFE

    static let NMIInterruptVector: Address = 0xFFFA

    /// Causes a interrupt to occur, if it is not inhibited by the `I` flag.
    func triggerIRQ() {
        guard !I else { return }

        interrupt = .IRQ
    }

    /// Causes a non-maskable interrupt to occur.
    func triggerNMI() {
        interrupt = .NMI
    }
}
