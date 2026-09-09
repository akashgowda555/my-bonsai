import AppKit
import SwiftUI

/// A borderless, transparent window pinned to the top edge of the screen.
/// Click-through while decorative; interactive only in grooming mode.
final class OverlayWindow: NSWindow {
    init(store: BonsaiStore) {
        let width: CGFloat = 240
        let height: CGFloat = 320
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .statusBar
        ignoresMouseEvents = true          // click-through by default
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false

        contentView = NSHostingView(rootView: BonsaiView(store: store))
        positionAtTopCenter()
    }

    func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let f = screen.frame
        let size = frame.size
        setFrameOrigin(NSPoint(x: f.midX - size.width / 2,
                               y: f.maxY - size.height))
    }

    /// In grooming mode the window catches clicks so puffs can be pruned.
    func setGrooming(_ on: Bool) {
        ignoresMouseEvents = !on
    }

    override var canBecomeKey: Bool { true }
}
