public enum Messages {
    static let focus = [
        "한 가지에만 집중해요.",
        "알림은 잠시 꺼 둬요.",
        "지금 이 작업만 생각해요.",
        "작게 나눠서 하나씩 끝내요.",
        "끝나면 쉬는 시간이 기다려요.",
    ]
    static let rest = [
        "잠깐 일어나서 몸을 풀어요.",
        "물 한 잔 마셔요.",
        "화면에서 눈을 떼고 먼 곳을 봐요.",
        "깊게 숨을 쉬어요.",
        "어깨에 힘을 빼요.",
    ]

    public static func line(for status: Status?) -> String {
        guard let status else { return "Claude Code에서 /pomodoro 로 시작해요." }
        if status.isPaused { return "잠시 멈췄어요. 준비되면 이어서 해요." }
        if status.isLongBreak { return "긴 휴식이에요. 산책 어때요?" }
        let pool = status.kind == .focus ? focus : rest
        return pool[(status.seq / 2) % pool.count]
    }
}
