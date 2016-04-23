@testable import NES

/// A mapper that has no internal logic.
internal class DummyMapper: IO {
    private var memory: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0xFF)

    func read(address: Address) -> UInt8 {
        return memory[Int(address)]
    }

    func write(address: Address, _ value: UInt8) {
        memory[Int(address)] = value
    }
}

internal extension Console {
    static func consoleWithDummyMapper() -> Console {
        return Console(mapper: DummyMapper())
    }
}
