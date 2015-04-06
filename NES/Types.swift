import Foundation

public typealias Address = UInt16

extension Address {
    init(_ page: UInt8, _ offset: UInt8) {
        self = UInt16(page) << 8 | UInt16(offset)
    }

    var page: UInt8 {
        return UInt8(self >> 8)
    }

    var offset: UInt8 {
        return UInt8(self & 0xFF)
    }
}
