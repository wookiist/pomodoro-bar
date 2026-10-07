import PomodoroCore
import SwiftUI

extension Status {
    var emoji: String { kind == .focus ? "🍅" : "☕️" }
    var title: String { "\(kind == .focus ? "집중" : isLongBreak ? "긴 휴식" : "휴식") · \(round)회차" }
    var tint: Color { kind == .focus ? .red : .green }
}

public struct MenuLabel: View {
    let status: Status?

    public init(status: Status?) { self.status = status }

    public var body: some View {
        if let status {
            Text("\(status.isPaused ? "⏸" : status.emoji) \(clock(status.leftMs))").monospacedDigit()
        } else {
            Image(systemName: "timer")
        }
    }
}

public struct Panel: View {
    let status: Status?
    let onQuit: () -> Void

    public init(status: Status?, onQuit: @escaping () -> Void = {}) {
        self.status = status
        self.onQuit = onQuit
    }

    public var body: some View {
        VStack(spacing: 14) {
            Text(status?.emoji ?? "🍅")
                .font(.system(size: 96))
                .opacity(status == nil || status?.isPaused == true ? 0.5 : 1)
                .padding(.top, 8)
            if let status {
                Text(status.isPaused ? "\(status.title) · 일시정지" : status.title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(clock(status.leftMs))
                    .font(.system(size: 52, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(status.isPaused ? .secondary : .primary)
                Capsule()
                    .fill(.primary.opacity(0.12))
                    .overlay(alignment: .leading) {
                        GeometryReader { box in
                            Capsule().fill(status.tint.opacity(status.isPaused ? 0.4 : 0.85))
                                .frame(width: max(6, box.size.width * status.progress))
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 8)
            } else {
                Text("타이머가 꺼져 있어요")
                    .font(.title3.weight(.semibold))
            }
            Text(Messages.line(for: status))
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 280)
        .modifier(PanelBackground(tint: status?.tint ?? .gray))
        .padding(12)
        .overlay(alignment: .topTrailing) {
            Button {
                onQuit()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
            .buttonStyle(.plain)
            .help("종료")
            .padding(16)
        }
    }
}


extension EnvironmentValues {
    @Entry public var rendersGlass = true
}

private struct PanelBackground: ViewModifier {
    let tint: Color
    @Environment(\.rendersGlass) private var rendersGlass

    func body(content: Content) -> some View {
        if rendersGlass {
            content.glassEffect(.regular.tint(tint.opacity(0.12)), in: .rect(cornerRadius: 28))
        } else {
            content.background(.white.opacity(0.25), in: .rect(cornerRadius: 28))
        }
    }
}
