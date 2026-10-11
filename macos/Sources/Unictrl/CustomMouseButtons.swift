/// G HUB single-key assignments, independent of the Windows keyboard-layout profile.
/// F13/F14/F15 are reserved globally only when the user enables the preset.
struct CustomMouseButtons {
    struct Result {
        var consumed: Bool
        var action: KeyAction?
    }

    private var held: Set<UInt16> = []

    mutating func handle(keyCode: UInt16, down: Bool, isRepeat: Bool, enabled: Bool) -> Result {
        // Finish an intercepted press even if the preset was turned off or the pointer crossed.
        // A release without an intercepted press must pass through (e.g. enabled mid-press).
        if !down { return Result(consumed: held.remove(keyCode) != nil, action: nil) }
        if held.contains(keyCode) { return Result(consumed: true, action: nil) }
        guard enabled, !isRepeat else { return Result(consumed: false, action: nil) }
        let action: KeyAction
        switch keyCode {
        case 105: action = .desktopLeft  // kVK_F13
        case 107: action = .desktopRight // kVK_F14
        case 113: action = .mute         // kVK_F15
        default: return Result(consumed: false, action: nil)
        }
        held.insert(keyCode)
        return Result(consumed: true, action: action)
    }
}
