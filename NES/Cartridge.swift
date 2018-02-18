import Foundation

public final class Cartridge {
    internal var CHRROM: Array<UInt8>

    internal let mapper: UInt8

    internal var PRGRAM: Array<UInt8>

    internal let PRGROM: Array<UInt8>

    internal var SRAM: Array<UInt8>

    public static func load(path: String) -> Cartridge? {
        return NSData(contentsOfFile: path)
            .map { data -> [UInt8] in
                let count = data.length / MemoryLayout<UInt8>.size
                var array = Array<UInt8>(repeating: 0, count: count)

                data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)

                return array
            }
            .flatMap { array -> Cartridge? in
                return Cartridge(array: array)
            }
    }

    init?(array: [UInt8]) {
        let a = UInt32(array[0]) << 24
        let b = UInt32(array[1]) << 16
        let c = UInt32(array[2]) << 8
        let d = UInt32(array[3])

        let magic: UInt32 = a | b | c | d

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

        PRGROM = Array(array[offset ..< offset + 16384 * PRGROMSize])
        offset += 16384 * PRGROMSize

        CHRROM = Array(array[offset ..< offset + 8192 * CHRROMSize])
        offset += 8192 * CHRROMSize

        PRGRAM = Array<UInt8>(repeating: 0x00, count: PRGRAMSize)

        SRAM = Array<UInt8>(repeating: 0x00, count: 0x2000)

        mapper = (flags7 & 0xF0) | (flags6 >> 4)
    }
}
