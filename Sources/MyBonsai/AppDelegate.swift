import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var window: OverlayWindow!
    private let store = BonsaiStore()
    private var groomItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = OverlayWindow(store: store)
        window.orderFrontRegardless()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "leaf.fill",
                                           accessibilityDescription: "My Bonsai")

        let menu = NSMenu()

        groomItem = NSMenuItem(title: "Grooming mode", action: #selector(toggleGrooming), keyEquivalent: "g")
        groomItem.target = self
        menu.addItem(groomItem)

        let show = NSMenuItem(title: "Show / hide", action: #selector(toggleVisible), keyEquivalent: "d")
        show.target = self
        menu.addItem(show)

        let replant = NSMenuItem(title: "Plant a new one", action: #selector(replant), keyEquivalent: "")
        replant.target = self
        menu.addItem(replant)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit My Bonsai",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc private func toggleGrooming() {
        store.isGrooming.toggle()
        window.setGrooming(store.isGrooming)
        groomItem.state = store.isGrooming ? .on : .off
    }

    @objc private func toggleVisible() {
        if window.isVisible { window.orderOut(nil) }
        else { window.orderFrontRegardless() }
    }

    @objc private func replant() {
        store.replant()
    }
}
