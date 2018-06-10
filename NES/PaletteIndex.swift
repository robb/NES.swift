import Foundation

internal typealias PaletteIndex = UInt8

internal extension PaletteIndex {
    var isOpaque: Bool {
        return self % 0x04 != 0
    }
}
