import Foundation

typealias ConsoleState = (a: UInt8, x: UInt8, y: UInt8, p: UInt8, sp: UInt8, cycle: Int, scanLine: Int)

func loadLog() -> [ConsoleState] {
    var result: [ConsoleState] = []

    let file = Bundle(for: NESTest.self).path(forResource: "nestest", ofType: "log")

    let scanner = try! Scanner(string: String(contentsOfFile: file!, encoding: .utf8) as String)

    while !scanner.isAtEnd {
        let state: ConsoleState = (
            a: scanner.scanHexValue(label: "A"),
            x: scanner.scanHexValue(label: "X"),
            y: scanner.scanHexValue(label: "Y"),
            p: scanner.scanHexValue(label: "P"),
            sp: scanner.scanHexValue(label: "SP"),
            cycle: scanner.scanIntegerValue(label: "CYC"),
            scanLine: scanner.scanIntegerValue(label: "SL")
        )

        result.append(state)
    }

    return result
}

extension Scanner {
    func scanHexValue(label: String) -> UInt8 {
        var result: UInt32 = 0x00

        scanUpTo("\(label):", into: nil)
        scanString("\(label):", into: nil)
        scanHexInt32(&result)

        return UInt8(truncatingIfNeeded: result)
    }

    func scanIntegerValue(label: String) -> Int {
        var result: Int32 = 0x00

        scanUpTo("\(label):", into: nil)
        scanString("\(label):", into: nil)
        scanInt32(&result)

        return Int(result)
    }
}
