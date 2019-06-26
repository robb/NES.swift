import Foundation

internal struct Sprite {
    var y: UInt8 = 0x00

    var tile: UInt8 = 0x00

    var attributes: UInt8 = 0x00

    var x: UInt8 = 0x00
}

extension Sprite {
    var patternTableAddress: Address {
        tile[bit: 0] ? 0x1000 : 0x0000
    }

    var lowPaletteByte: UInt8 {
        (attributes & 0x01) * 0xFF
    }

    var highPaletteByte: UInt8 {
        ((attributes & 0x02) >> 1) * 0xFF
    }

    var isInFront: Bool {
        !attributes[bit: 5]
    }

    var isFlippedHorizontally: Bool {
        attributes[bit: 6]
    }

    var isFlippedVertically: Bool {
        attributes[bit: 7]
    }
}

// A `Sprite` that has been loaded for display on the current scan line.
internal struct ResolvedSprite {
    var data: UInt32 = 0x0000

    var x: UInt8 = 0x00

    var isInFront: Bool = false

    var isSpriteZero: Bool = false
}
