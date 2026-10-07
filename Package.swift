// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PomodoroBar",
    platforms: [.macOS(.v26)],
    targets: [
        .target(name: "PomodoroCore"),
        .target(name: "PomodoroUI", dependencies: ["PomodoroCore"]),
        .executableTarget(name: "PomodoroBar", dependencies: ["PomodoroCore", "PomodoroUI"]),
        .executableTarget(name: "PomodoroSnapshot", dependencies: ["PomodoroCore", "PomodoroUI"]),
        .testTarget(name: "PomodoroCoreTests", dependencies: ["PomodoroCore"]),
    ]
)
