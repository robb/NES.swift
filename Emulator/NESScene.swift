import SpriteKit
import NES

class NESScene: SKScene {
    private let console: Console

    private var lastFrame: Int = 0

    private var lastTime: CFTimeInterval? = nil

    private let node: SKSpriteNode

    static let screenSize = CGSize(width: 256, height: 240)

    init(file: String) {
        let cartridge = Cartridge.load(path: file)!

        console = Console(cartridge: cartridge)

        node = SKSpriteNode()
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.size = NESScene.screenSize

        super.init(size: NESScene.screenSize)

        scaleMode = .aspectFit

        addChild(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x007E:
            console.controller1.insert(.up)
        case 0x007D:
            console.controller1.insert(.down)
        case 0x007B:
            console.controller1.insert(.left)
        case 0x007C:
            console.controller1.insert(.right)
        case 0x0006: // Z
            console.controller1.insert(.a)
        case 0x0007: // X
            console.controller1.insert(.b)
        case 0x24: // Return
            console.controller1.insert(.start)
        case 0x3C: // Right Shift
            console.controller1.insert(.select)
        default:
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0x007E:
            console.controller1.remove(.up)
        case 0x007D:
            console.controller1.remove(.down)
        case 0x007B:
            console.controller1.remove(.left)
        case 0x007C:
            console.controller1.remove(.right)
        case 0x0006: // Z
            console.controller1.remove(.a)
        case 0x0007: // X
            console.controller1.remove(.b)
        case 0x24: // Return
            console.controller1.remove(.start)
        case 0x3C: // Right Shift
            console.controller1.remove(.select)
        default:
            super.keyUp(with: event)
        }
    }

    override func update(_ currentTime: CFTimeInterval) {
        let delta = currentTime - (lastTime ?? currentTime)

        console.step(time: delta)

        if console.frames > lastFrame {
            let texture = SKTexture(data: console.screenData as Data, size: NESScene.screenSize, flipped: true)
            texture.filteringMode = .nearest

            node.texture = texture

            lastFrame = console.frames
        }

        lastTime = currentTime
    }
}
