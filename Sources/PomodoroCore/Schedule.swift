import Foundation

public struct Plan: Codable, Equatable, Sendable {
    public var startedAt: Double
    public var focusMin: Double
    public var breakMin: Double
    public var pausedAt: Double?
    public var pausedMs: Double
    public var skippedMs: Double

    public init(startedAt: Double, focusMin: Double, breakMin: Double, pausedAt: Double? = nil, pausedMs: Double = 0, skippedMs: Double = 0) {
        self.startedAt = startedAt
        self.focusMin = focusMin
        self.breakMin = breakMin
        self.pausedAt = pausedAt
        self.pausedMs = pausedMs
        self.skippedMs = skippedMs
    }
}

public enum Kind: Sendable {
    case focus
    case rest
}

public struct Status: Equatable, Sendable {
    public let kind: Kind
    public let round: Int
    public let seq: Int
    public let leftMs: Double
    public let totalMs: Double
    public let isPaused: Bool

    public var isLongBreak: Bool { kind == .rest && round % 4 == 0 }
    public var progress: Double { totalMs > 0 ? 1 - leftMs / totalMs : 0 }
}

private let minute = 60_000.0

public func status(of plan: Plan, at now: Double) -> Status {
    let phases: [(kind: Kind, round: Int, ms: Double)] = (1...4).flatMap { round in
        [(Kind.focus, round, plan.focusMin * minute), (Kind.rest, round, (round == 4 ? 3 : 1) * plan.breakMin * minute)]
    }
    let lapMs = phases.reduce(0) { $0 + $1.ms }
    let elapsed = max(0, (plan.pausedAt ?? now) - plan.startedAt - plan.pausedMs + plan.skippedMs)
    let lap = Int(floor(elapsed / lapMs))
    var rest = elapsed - Double(lap) * lapMs
    var i = 0
    while i < phases.count - 1, rest >= phases[i].ms {
        rest -= phases[i].ms
        i += 1
    }
    let phase = phases[i]
    return Status(
        kind: phase.kind,
        round: lap * 4 + phase.round,
        seq: lap * phases.count + i,
        leftMs: max(0, phase.ms - rest),
        totalMs: phase.ms,
        isPaused: plan.pausedAt != nil
    )
}

public func clock(_ ms: Double) -> String {
    let seconds = Int((ms / 1000).rounded(.up))
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
}
