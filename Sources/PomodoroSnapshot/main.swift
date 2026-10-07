import AppKit
import PomodoroCore
import PomodoroUI
import SwiftUI

let minute = 60_000.0
let plan = Plan(startedAt: 0, focusMin: 25, breakMin: 5)
let cases: [(String, Status?)] = [
    ("focus", status(of: plan, at: 11 * minute + 47_000)),
    ("rest", status(of: plan, at: 25 * minute + 48_000)),
    ("long-rest", status(of: plan, at: 3 * 30 * minute + 26 * minute)),
    ("paused", status(of: Plan(startedAt: 0, focusMin: 25, breakMin: 5, pausedAt: 6 * minute), at: 9 * minute)),
    ("idle", nil),
]
let out = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? ".")

MainActor.assumeIsolated {
    for (name, status) in cases {
        let view = HStack(spacing: 24) {
            Panel(status: status)
            MenuLabel(status: status).padding(8).background(.gray.opacity(0.2), in: .capsule)
        }
        .padding(20)
        .environment(\.rendersGlass, false)
        .background(LinearGradient(colors: [.indigo.opacity(0.6), .teal.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage, let tiff = image.tiffRepresentation,
              let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) else { continue }
        try! png.write(to: out.appendingPathComponent("\(name).png"))
        print(name)
    }
}

let live = Store.latestPlan().map { status(of: $0, at: Date().timeIntervalSince1970 * 1000) }
print("live:", live.map { "\($0.kind == .focus ? "focus" : "rest") \($0.round) \(clock($0.leftMs))\($0.isPaused ? " paused" : "")" } ?? "off")
