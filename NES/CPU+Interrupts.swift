import Foundation

internal enum Interrupt {
    case none
    case irq
    case nmi
}

/// Interrupts.
internal extension CPU {
    static let irqInterruptVector: Address = 0xFFFE

    static let nmiInterruptVector: Address = 0xFFFA

    /// Causes a interrupt to occur, if it is not inhibited by the `I` flag.
    func triggerIRQ() {
        guard !i else { return }

        interrupt = .irq
    }

    /// Causes a non-maskable interrupt to occur.
    func triggerNMI() {
        interrupt = .nmi
    }
}
