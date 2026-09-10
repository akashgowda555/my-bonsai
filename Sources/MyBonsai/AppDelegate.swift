import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var window: OverlayWindow!
    private let store = PlantStore()
    private var groomItem: NSMenuItem!

    // Break detection -> bloom.
    private var idleTimer: Timer?
    private var didBloomThisBreak = false
    #if DEBUG
    private let breakThreshold: TimeInterval = 8
    #else
    private let breakThreshold: TimeInterval = 3 * 60
    #endif

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = OverlayWindow(store: store)
        window.orderFrontRegardless()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "leaf.fill",
                                           accessibilityDescription: "My Plant")

        let menu = NSMenu()

        groomItem = NSMenuItem(title: "Grooming mode", action: #selector(toggleGrooming), keyEquivalent: "g")
        groomItem.target = self
        menu.addItem(groomItem)

        let bloom = NSMenuItem(title: "Bloom now (test)", action: #selector(bloomNow), keyEquivalent: "b")
        bloom.target = self
        menu.addItem(bloom)

        let show = NSMenuItem(title: "Show / hide", action: #selector(toggleVisible), keyEquivalent: "d")
        show.target = self
        menu.addItem(show)

        let replant = NSMenuItem(title: "Plant a new one", action: #selector(replant), keyEquivalent: "")
        replant.target = self
        menu.addItem(replant)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit My Plant",
                                action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu

        idleTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.checkBreak()
        }
    }

    /// Seconds since the last user input of any kind.
    private func systemIdleSeconds() -> TimeInterval {
        let types: [CGEventType] = [.mouseMoved, .keyDown, .leftMouseDown, .rightMouseDown, .scrollWheel]
        return types.map { CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0) }.min() ?? 0
    }

    private func checkBreak() {
        let idle = systemIdleSeconds()
        if idle >= breakThreshold, !didBloomThisBreak {
            window.scene.bloom()
            didBloomThisBreak = true
        }
        if idle < 2 { didBloomThisBreak = false }   // back at the desk; arm for next break
    }

    @objc private func toggleGrooming() {
        let on = groomItem.state != .on
        window.setGrooming(on)
        groomItem.state = on ? .on : .off
    }

    @objc private func bloomNow() { window.scene.bloom() }

    @objc private func toggleVisible() {
        if window.isVisible { window.orderOut(nil) } else { window.orderFrontRegardless() }
    }

    @objc private func replant() { window.scene.replant() }
}
