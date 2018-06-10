import Foundation

internal extension UInt32 {
    func get(nibble: Int) -> UInt8 {
        precondition(0 <= nibble && nibble <= 7)

        let offset = nibble * 4

        let mask = UInt32(0x0F << offset)

        return UInt8(truncatingIfNeeded: (self & mask) >> offset)
    }

    subscript(nibble nibble: Int) -> UInt8 {
        get {
            return get(nibble: nibble)
        }
    }
}
