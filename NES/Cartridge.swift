import Foundation

public struct Cartridge {
    public let mapper: UInt8

    public static func load(path: String) -> Cartridge? {
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

        let PRGROMSize = array[4]
        let CHRROMSize = array[5]
        let flags6 = array[6]
        let flags7 = array[7]
        let PRGRAMSize = array[8]
        let flags9 = array[7]

        mapper = (flags7 & 0xF0) | (flags6 >> 4)
    }
}
