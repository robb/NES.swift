import Foundation

public final class Cartridge {
    internal var chrrom: ContiguousArray<UInt8>

    internal let mapper: UInt8

    internal var prgram: ContiguousArray<UInt8>

    internal let prgrom: ContiguousArray<UInt8>

    internal var sram: ContiguousArray<UInt8>

    public static func load(path: String) -> Cartridge? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))

        return data
            .flatMap { data in
                return Cartridge(data: data)
            }
    }

    init?(data: Data) {
        let a = UInt32(data[0]) << 24
        let b = UInt32(data[1]) << 16
        let c = UInt32(data[2]) << 8
        let d = UInt32(data[3])

        let magic: UInt32 = a | b | c | d

        if magic != 0x4E45531A { return nil }

        let prgromSize = Int(data[4])
        let chrromSize = Int(data[5])
        let flags6 = data[6]
        let flags7 = data[7]
        let prgramSize = Int(data[8])

        var offset = 16

        // Check if a trainer is present
        if (flags6 & 0x04) != 0 {
            offset += 512
        }

        prgrom = ContiguousArray(data[offset ..< offset + 16384 * prgromSize])
        offset += 16384 * prgromSize

        chrrom = ContiguousArray(data[offset ..< offset + 8192 * chrromSize])
        offset += 8192 * chrromSize

        prgram = ContiguousArray(repeating: 0x00, count: prgramSize)

        sram = ContiguousArray(repeating: 0x00, count: prgramSize)

        mapper = (flags7 & 0xF0) | (flags6 >> 4)
    }
}
