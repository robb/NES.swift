import Cocoa
import SpriteKit

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var view: SKView!
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        window.contentAspectRatio = NESScene.screenSize
        window.contentMinSize = NESScene.screenSize
        window.setContentSize(NESScene.screenSize)

        window.center()
    }

    func application(sender: NSApplication, openFile filename: String) -> Bool {
        let scene = NESScene(file: filename)

        view!.presentScene(scene)
        view!.ignoresSiblingOrder = true
        view!.showsFPS = true

        return true
    }
}
