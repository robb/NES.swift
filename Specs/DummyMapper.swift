import NES

/// A mapper that has no internal logic.
internal struct DummyMapper: Mapper {
    private var memory: Array<UInt8> = Array(count: 0x10000, repeatedValue: 0xFF)

    func read(address: Address) -> UInt8 {
        return memory[Int(address)]
    }

    mutating func write(address: Address, _ value: UInt8) {
        memory[Int(address)] = value
    }
}
