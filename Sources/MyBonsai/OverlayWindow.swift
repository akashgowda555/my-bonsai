import AppKit
import SpriteKit

/// A borderless, transparent window pinned to the top edge of the screen,
/// hosting the plant as a SpriteKit scene. Click-through while decorative;
/// interactive only in grooming mode so strands can be trimmed.
final class OverlayWindow: NSWindow {
    let scene: PlantScene
    private let skView: SKView

    init(store: PlantStore) {
        let width: CGFloat = 300
        let height: CGFloat = 480
        let rect = NSRect(x: 0, y: 0, width: width, height: height)

        skView = SKView(frame: rect)
        skView.allowsTransparency = true
        scene = PlantScene(size: rect.size, store: store)

        super.init(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .statusBar
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false

        skView.presentScene(scene)
        contentView = skView
        positionAtTopCenter()
    }

    func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let f = screen.frame
        setFrameOrigin(NSPoint(x: f.midX - frame.width / 2, y: f.maxY - frame.height))
    }

    func setGrooming(_ on: Bool) { ignoresMouseEvents = !on }

    override var canBecomeKey: Bool { true }
}
