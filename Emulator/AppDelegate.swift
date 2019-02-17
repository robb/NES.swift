import Cocoa
import SpriteKit

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var view: SKView!
    @IBOutlet weak var window: NSWindow!

    @objc func applicationDidFinishLaunching(_ notification: Notification) {
        window.contentAspectRatio = NESScene.screenSize
        window.contentMinSize = NESScene.screenSize
        window.setContentSize(NESScene.screenSize)

        if let path = ProcessInfo.processInfo.environment["file"] {
            print(path)
            open(path: path)
        }
    }

    @objc func application(_ sender: NSApplication, openFile path: String) -> Bool {
        open(path: path)

        return true
    }

    func open(path: String) {
        let scene = NESScene(file: path)

        view!.presentScene(scene)
        view!.ignoresSiblingOrder = true
        view!.showsFPS = true
    }
}
