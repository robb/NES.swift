import Foundation

internal extension PPU {
    func step() {
        cycle += 1

        if cycle > 340 {
            cycle = 0

            scanLine += 1

            if scanLine > 260 {
                scanLine = -1
            }
        }
    }
}
