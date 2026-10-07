import AppKit
import PomodoroCore
import PomodoroUI
import SwiftUI

@MainActor
@Observable
final class TimerModel {
    private(set) var status: Status?
    private var timer: Timer?

    init() {
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        let now = Date().timeIntervalSince1970 * 1000
        let next = Store.latestPlan().map { PomodoroCore.status(of: $0, at: now) }
        if next != status { status = next }
    }
}

struct PomodoroBarApp: App {
    @State private var model = TimerModel()

    var body: some Scene {
        MenuBarExtra {
            Panel(status: model.status) { NSApp.terminate(nil) }
        } label: {
            MenuLabel(status: model.status)
        }
        .menuBarExtraStyle(.window)
    }
}

NSApplication.shared.setActivationPolicy(.accessory)
PomodoroBarApp.main()
