@testable import NES

/// A mapper that has no internal logic.
internal final class DummyMapper: Mapper {
    private var memory: Array<UInt8> = Array(repeating: 0xFF, count: 0x10000)

    override func read(_ address: Address) -> UInt8 {
        return memory[Int(address)]
    }

    override func write(_ address: Address, _ value: UInt8) {
        memory[Int(address)] = value
    }
}

internal extension Console {
    static func consoleWithDummyMapper() -> Console {
        return Console(mapper: DummyMapper())
    }
}
