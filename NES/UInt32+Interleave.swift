import Foundation
import simd

internal extension UInt32 {
    /// Interleaves its inputs such that each nibble of the resulting value
    /// contains one bit of each input byte.
    ///
    /// E.g. given:
    /// ```
    /// x = xxxxxxxx
    /// y = yyyyyyyy
    /// z = zzzzzzzz
    /// w = wwwwwwww
    /// ```
    ///
    /// the result is
    ///
    /// ```
    /// wzyxwzyxwzyxwzyxwzyxwzyxwzyxwzyx
    /// ```
    /// .
    static func interleaving(_ x: UInt8, _ y: UInt8, _ z: UInt8, _ w: UInt8) -> UInt32 {
        var bytes = SIMD4<UInt32>(
            UInt32(truncatingIfNeeded: x),
            UInt32(truncatingIfNeeded: y),
            UInt32(truncatingIfNeeded: z),
            UInt32(truncatingIfNeeded: w)
        )

        // Spread out each byte over 32 bits, e.g.
        // `0b11111111` becomes `0b00010001000100010001000100010001`
        bytes = (bytes | (bytes &<< 8)) & 0x00FF00FF
        bytes = (bytes | (bytes &<< 4)) & 0x0F0F0F0F
        bytes = (bytes | (bytes &<< 2)) & 0x33333333
        bytes = (bytes | (bytes &<< 1)) & 0x55555555
        bytes = (bytes | (bytes &<< 8)) & 0x00FF00FF
        bytes = (bytes | (bytes &<< 4)) & 0x0F0F0F0F
        bytes = (bytes | (bytes &<< 2)) & 0x33333333

        bytes &<<= SIMD4<UInt32>(0, 1, 2, 3)

        return bytes.x | bytes.y | bytes.z | bytes.w
    }

    var reversedNibbleOrder: UInt32 {
        let spriteData = self

        let a = (spriteData & 0x0000000F) << 28
        let b = (spriteData & 0x000000F0) << 20
        let c = (spriteData & 0x00000F00) << 12
        let d = (spriteData & 0x0000F000) <<  4
        let e = (spriteData & 0x000F0000) >>  4
        let f = (spriteData & 0x00F00000) >> 12
        let g = (spriteData & 0x0F000000) >> 20
        let h = (spriteData & 0xF0000000) >> 28

        return a | b | c | d | e | f | g | h
    }
}
