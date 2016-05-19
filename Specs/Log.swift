import Foundation

typealias ConsoleState = (A: UInt8, X: UInt8, Y: UInt8, P: UInt8, SP: UInt8, cycle: Int, scanLine: Int)

func loadLog() -> [ConsoleState] {
    var result: [ConsoleState] = []

    let file = NSBundle(forClass: NESTest.self).pathForResource("nestest", ofType: "log")

    let scanner = try! NSScanner(string: NSString(contentsOfFile: file!, encoding: NSUTF8StringEncoding) as String)

    while !scanner.atEnd {
        let state: ConsoleState = (
            A: scanner.scanHexValue("A"),
            X: scanner.scanHexValue("X"),
            Y: scanner.scanHexValue("Y"),
            P: scanner.scanHexValue("P"),
            SP: scanner.scanHexValue("SP"),
            cycle: scanner.scanIntegerValue("CYC"),
            scanLine: scanner.scanIntegerValue("SL")
        )

        result.append(state)
    }

    return result
}

extension NSScanner {
    func scanHexValue(label: String) -> UInt8 {
        var result: UInt32 = 0x00

        scanUpToString("\(label):", intoString: nil)
        scanString("\(label):", intoString: nil)
        scanHexInt(&result)

        return UInt8(truncatingBitPattern: result)
    }

    func scanIntegerValue(label: String) -> Int {
        var result: Int32 = 0x00

        scanUpToString("\(label):", intoString: nil)
        scanString("\(label):", intoString: nil)
        scanInt(&result)

        return Int(result)
    }
}
