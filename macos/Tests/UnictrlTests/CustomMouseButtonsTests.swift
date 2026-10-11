import Foundation
import Testing
@testable import Unictrl

@Suite struct CustomMouseButtonsTests {
    @Test func actionsFireOnceAndReleasesAreConsumed() {
        var buttons = CustomMouseButtons()
        let assignments: [(UInt16, KeyAction)] = [(105, .desktopLeft), (107, .desktopRight), (113, .mute)]
        for (code, action) in assignments {
            let press = buttons.handle(keyCode: code, down: true, isRepeat: false, enabled: true)
            #expect(press.consumed && press.action == action)
            let repeatPress = buttons.handle(keyCode: code, down: true, isRepeat: true, enabled: true)
            #expect(repeatPress.consumed && repeatPress.action == nil)
            let release = buttons.handle(keyCode: code, down: false, isRepeat: false, enabled: true)
            #expect(release.consumed && release.action == nil)
        }
    }

    @Test func disabledAndUnassignedKeysPassThrough() {
        var buttons = CustomMouseButtons()
        #expect(!buttons.handle(keyCode: 105, down: true, isRepeat: false, enabled: false).consumed)
        #expect(!buttons.handle(keyCode: 105, down: false, isRepeat: false, enabled: true).consumed)
        #expect(!buttons.handle(keyCode: 0, down: true, isRepeat: false, enabled: true).consumed)
        #expect(!buttons.handle(keyCode: 105, down: true, isRepeat: true, enabled: true).consumed)
    }

    @Test func disablingDuringPressStillConsumesRelease() {
        var buttons = CustomMouseButtons()
        _ = buttons.handle(keyCode: 113, down: true, isRepeat: false, enabled: true)
        #expect(buttons.handle(keyCode: 113, down: true, isRepeat: true, enabled: false).action == nil)
        #expect(buttons.handle(keyCode: 113, down: false, isRepeat: false, enabled: false).consumed)
        #expect(!buttons.handle(keyCode: 113, down: true, isRepeat: false, enabled: false).consumed)
    }

    @Test func oldSettingsDefaultToOffAndNewSettingsRoundTrip() throws {
        let old = try JSONDecoder().decode(UnictrlSettings.self, from: Data("{}".utf8))
        #expect(!old.g502xButtons)
        var settings = old
        settings.g502xButtons = true
        let decoded = try JSONDecoder().decode(UnictrlSettings.self, from: JSONEncoder().encode(settings))
        #expect(decoded.g502xButtons)
    }
}
