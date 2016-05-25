import Foundation

internal final class Cartridge {
    var CHRROM: Array<UInt8>

    let mapper: UInt8

    var PRGRAM: Array<UInt8>

    let PRGROM: Array<UInt8>

    var SRAM: Array<UInt8>

    static func load(path: String) -> Cartridge? {
        return NSData(contentsOfFile: path)
            .map { data -> [UInt8] in
                let count = data.length / sizeof(UInt8)
                var array = Array<UInt8>(count: count, repeatedValue: 0)

                data.getBytes(&array, length:count * sizeof(UInt8))

                return array
            }
            .flatMap { array -> Cartridge? in
                return Cartridge(array: array)
            }
    }

    init?(array: [UInt8]) {
        let magic: UInt32 = UInt32(array[0]) << 24
                          | UInt32(array[1]) << 16
                          | UInt32(array[2]) << 8
                          | UInt32(array[3])

        if magic != 0x4E45531A { return nil }

        let PRGROMSize = Int(array[4])
        let CHRROMSize = Int(array[5])
        let flags6 = array[6]
        let flags7 = array[7]
        let PRGRAMSize = Int(array[8])

        var offset = 16

        // Check if a trainer is present
        if (flags6 & 0x04) != 0 {
            offset += 512
        }

        PRGROM = Array(array[offset..<offset + 16384 * PRGROMSize])
        offset += 16384 * PRGROMSize

        CHRROM = Array(array[offset..<offset + 8192 * CHRROMSize])
        offset += 8192 * CHRROMSize

        PRGRAM = Array<UInt8>(count: PRGRAMSize, repeatedValue: 0x00)

        SRAM = Array<UInt8>(count: 0x2000, repeatedValue: 0x00)

        mapper = (flags7 & 0xF0) | (flags6 >> 4)
    }
}
