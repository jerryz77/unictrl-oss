import AppKit
import CoreGraphics

/// Functions of the MX Keys special keys, performed on the computer under the pointer.
/// Values travel in the `action` message; the Windows receiver mirrors them.
enum KeyAction: UInt8 {
    case taskView = 1     // F3: Mission Control / Task View
    case apps = 2         // F4: Apps / Start menu
    case showDesktop = 3  // F5
    case screenshot = 4   // screenshot key: CleanShot X area capture / PixPin screenshot (both Ctrl+Shift+A)
    case lock = 5         // lock key
    case desktopLeft = 6
    case desktopRight = 7
    case mute = 8

    /// MX Keys (B35B) control IDs taken over through HID++ 0x1B04.
    static let controls: [UInt16: KeyAction] = [0x00E0: .taskView, 0x00E1: .apps, 0x006E: .showDesktop]

    /// Performs the Mac side of the action.
    func performOnMac() {
        switch self {
        case .taskView:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Mission Control.app"))
        case .apps:
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.apps.launcher") {
                NSWorkspace.shared.open(url)
            }
        case .showDesktop:
            Self.post(keyCode: 103, flags: .maskSecondaryFn) // F11 = Show Desktop
        case .screenshot:
            Self.post(keyCode: 0, flags: [.maskControl, .maskShift]) // CleanShot X: Ctrl+Shift+A
        case .lock:
            Self.post(keyCode: 12, flags: [.maskControl, .maskCommand]) // Ctrl+Cmd+Q
        case .desktopLeft:
            Self.post(keyCode: 123, flags: .maskControl) // Control+Left: previous Space
        case .desktopRight:
            Self.post(keyCode: 124, flags: .maskControl) // Control+Right: next Space
        case .mute:
            // NX_KEYTYPE_MUTE (7), NX_KEYDOWN/UP. Do not run an AppleScript or change volume.
            for state in [0x0A, 0x0B] {
                NSEvent.otherEvent(with: .systemDefined, location: .zero, modifierFlags: [],
                                   timestamp: 0, windowNumber: 0, context: nil, subtype: 8,
                                   data1: (7 << 16) | (state << 8), data2: -1)?
                    .cgEvent?.post(tap: .cghidEventTap)
            }
        }
        Log.write("action_mac", "\(self)")
    }

    /// Posts a shortcut whose modifiers come from the event itself, so modifiers still physically
    /// held by the keyboard's own macro do not change it.
    private static func post(keyCode: CGKeyCode, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .privateState)
        for down in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: down) else { continue }
            event.flags = flags
            event.post(tap: .cghidEventTap)
        }
    }
}
