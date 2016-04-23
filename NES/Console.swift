import Foundation

public final class Console {
    internal let CPU: NES.CPU

    internal let mapper: IO

    public init(cartridge: Cartridge) {
        precondition(cartridge.mapper == 000 || cartridge.mapper == 002)

        mapper = Mapper002(cartridge: cartridge)

        CPU = NES.CPU(mapper: mapper)
    }
}
