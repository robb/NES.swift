import Foundation

internal extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self.init(UInt16(high) << 8 | UInt16(low))
    }
}
