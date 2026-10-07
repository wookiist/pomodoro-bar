import Foundation
import Testing

@testable import PomodoroCore

private let minute = 60_000.0

private func at(_ plan: Plan, _ ms: Double) -> String {
    let s = status(of: plan, at: ms)
    return "\(s.kind == .focus ? "focus" : "rest") \(s.round) \(clock(s.leftMs))\(s.isPaused ? " paused" : "")"
}

@Test func alternatesWithALongFourthBreak() {
    let p = Plan(startedAt: 0, focusMin: 25, breakMin: 5)
    #expect(at(p, 0) == "focus 1 25:00")
    #expect(at(p, 25 * minute) == "rest 1 05:00")
    #expect(at(p, 30 * minute) == "focus 2 25:00")
    #expect(at(p, 3 * 30 * minute + 25 * minute) == "rest 4 15:00")
    #expect(status(of: p, at: 3 * 30 * minute + 25 * minute).isLongBreak)
    #expect(at(p, 4 * 25 * minute + 6 * 5 * minute) == "focus 5 25:00")
}

@Test func pauseAndSkipFollowThePlanFields() {
    let paused = Plan(startedAt: 0, focusMin: 25, breakMin: 5, pausedAt: 10 * minute)
    #expect(at(paused, 40 * minute) == "focus 1 15:00 paused")
    let resumed = Plan(startedAt: 0, focusMin: 25, breakMin: 5, pausedMs: 30 * minute)
    #expect(at(resumed, 40 * minute) == "focus 1 15:00")
    let skipped = Plan(startedAt: 0, focusMin: 25, breakMin: 5, skippedMs: 15 * minute)
    #expect(at(skipped, 10 * minute) == "rest 1 05:00")
}

@Test func matchesTheModOnTheSameInputs() {
    let p = Plan(startedAt: 1_000_000, focusMin: 1, breakMin: 1)
    #expect(at(p, 1_000_000 + 59_001) == "focus 1 00:01")
    #expect(at(p, 1_000_000 + 60_000) == "rest 1 01:00")
}

@Test func readsTheNewestPomodoroStoreAndIgnoresOthers() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let write = { (name: String, json: String, age: TimeInterval) in
        let url = dir.appendingPathComponent(name)
        try json.write(to: url, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(-age)], ofItemAtPath: url.path)
    }
    #expect(Store.latestPlan(in: dir) == nil)
    let plan = #"{"plan":{"startedAt":5,"focusMin":25,"breakMin":5,"pausedAt":null,"pausedMs":0,"skippedMs":0}}"#
    try write("pomodoro_wookiist-a.json", plan, 60)
    try write("status-bar_wookiist-b.json", #"{"limits":[]}"#, 0)
    #expect(Store.latestPlan(in: dir) == Plan(startedAt: 5, focusMin: 25, breakMin: 5))
    try write("pomodoro_inline-c.json", "{}", 0)
    #expect(Store.latestPlan(in: dir) == nil)
    try write("pomodoro_inline-c.json", #"{"plan":{"startedAt":5,"focusMin":0,"breakMin":5,"pausedMs":0,"skippedMs":0}}"#, 0)
    #expect(Store.latestPlan(in: dir) == nil)
}

@Test func picksALineForEveryState() {
    let p = Plan(startedAt: 0, focusMin: 25, breakMin: 5)
    #expect(Messages.line(for: nil).contains("/pomodoro"))
    #expect(Messages.focus.contains(Messages.line(for: status(of: p, at: 0))))
    #expect(Messages.rest.contains(Messages.line(for: status(of: p, at: 25 * minute))))
    #expect(Messages.line(for: status(of: p, at: 3 * 30 * minute + 25 * minute)) == "긴 휴식이에요. 산책 어때요?")
}
