import AppKit

// Menu-bar-only app: no Dock icon, no window in the app switcher.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
