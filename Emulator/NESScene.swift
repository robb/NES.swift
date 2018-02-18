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
