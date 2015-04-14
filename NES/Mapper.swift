import Foundation

public protocol Mapper {
    func read(address: Address) -> UInt8
    mutating func write(address: Address, _ value: UInt8)
}
