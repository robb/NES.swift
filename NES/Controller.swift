import Foundation

struct Controller {
    var index: UInt8 = 0

    var pressed: Buttons = .none

    var strobing: Bool = false

    mutating func read() -> UInt8 {
        defer {
            index = index &+ 1

            if strobing {
                index = 0
            }
        }

        guard index < 8 else { return 0 }

        return (pressed.rawValue >> index) & 0x01
    }

    mutating func write(value: UInt8) {
        strobing = value[bit: 0]

        if strobing {
            index = 0
        }
    }
}

public struct Buttons: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let none   = Buttons(rawValue: 0)

    public static let a      = Buttons(rawValue: 1 << 0)

    public static let b      = Buttons(rawValue: 1 << 1)

    public static let select = Buttons(rawValue: 1 << 2)

    public static let start  = Buttons(rawValue: 1 << 3)

    public static let up     = Buttons(rawValue: 1 << 4)

    public static let down   = Buttons(rawValue: 1 << 5)

    public static let left   = Buttons(rawValue: 1 << 6)

    public static let right  = Buttons(rawValue: 1 << 7)
}
