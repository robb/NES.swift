import Foundation

private func pad(string: String, length: Int, character: Character = " ") -> String {
    if length <= string.characters.count {
        return string
    } else {
        return String(count: length - string.characters.count, repeatedValue: character) + string
    }
}

internal func format(value: UInt16) -> String {
    let hexString = String(value, radix: 16, uppercase: true)

    return "0x\(pad(hexString, length: 4, character: "0"))"
}

internal func format(value: UInt8) -> String {
    let hexString = String(value, radix: 16, uppercase: true)

    return "0x\(pad(hexString, length: 2, character: "0"))"
}
