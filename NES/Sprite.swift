import Foundation

internal struct Sprite {
    var y: UInt8 = 0x00

    var tile: UInt8 = 0x00

    var attributes: UInt8 = 0x00

    var x: UInt8 = 0x00
}

extension Sprite {
    var patternTableAddress: Address {
        return tile[0] ? 0x1000 : 0x0000
    }

    var palette: UInt8 {
        return attributes & 0x03
    }

    var isInFront: Bool {
        return !attributes[5]
    }

    var isFlippedHorizontally: Bool {
        return attributes[6]
    }

    var isFlippedVertically: Bool {
        return attributes[7]
    }
}

// A `Sprite` that has been loaded for display on the current scan line.
internal struct ResolvedSprite {
    var data: UInt32 = 0x0000

    var x: UInt8 = 0x00

    var isInFront: Bool = false
}
