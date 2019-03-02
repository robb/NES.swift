import Foundation

internal typealias PaletteIndex = UInt8

internal extension PaletteIndex {
    var isOpaque: Bool {
        return self[bit: 2]
    }
}
