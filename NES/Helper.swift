import Foundation

private func pad(string: String, length: Int, character: Character = " ") -> String {
    if length <= string.count {
        return string
    } else {
        return String(repeating: character, count: length - string.count) + string
    }
}

internal func format(_ value: UInt16) -> String {
    let hexString = String(value, radix: 16, uppercase: true)

    return "0x\(pad(string: hexString, length: 4, character: "0"))"
}

internal func format(_ value: UInt8) -> String {
    let hexString = String(value, radix: 16, uppercase: true)

    return "0x\(pad(string: hexString, length: 2, character: "0"))"
}
