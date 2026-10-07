# Pomodoro Bar

Claude Code [pomodoro mod](https://github.com/wookiist/claude-plugins/tree/main/plugins/pomodoro)의 타이머를 macOS 메뉴 막대에 보여주는 앱이에요. 타이머를 조작하지 않고, Claude Code에서 `/pomodoro`로 돌리는 타이머를 그대로 따라가요.

mod는 Claude Code에서 아래 명령으로 설치해요.

```
/plugin install pomodoro --marketplace wookiist/claude-plugins
```

메뉴 막대에는 `🍅 24:13`(집중), `☕️ 04:12`(휴식), `⏸ 24:13`(일시정지)처럼 보여요. 타이머가 꺼져 있으면 시계 아이콘만 보여요. 아이콘을 누르면 Liquid Glass 패널이 열리고, 가운데에 큰 토마토나 커피, 회차, 남은 시간, 진행 막대, 짧은 한마디가 보여요.

## 동작 방식

mod는 타이머 일정을 `~/.claude/plugins/store/pomodoro_*.json`의 `plan`에 저장해요. 앱은 1초마다 가장 최근에 바뀐 이 파일을 읽고, mod와 같은 규칙으로 단계와 남은 시간을 계산해요. 4번째 휴식은 휴식 시간의 3배예요. `CLAUDE_CONFIG_DIR`을 쓰면 그 아래 `plugins/store`를 읽어요.

## 빌드와 실행

macOS 26 이상과 Xcode 26 이상이 필요해요.

```bash
./scripts/build_app.sh
open "dist/Pomodoro Bar.app"
```

Dock 아이콘 없이 메뉴 막대에만 떠요. 패널 오른쪽 위의 `×`로 종료해요. 로그인할 때 자동으로 켜려면 앱을 `/Applications`로 옮긴 뒤 시스템 설정의 로그인 항목에 추가해요.

## 확인

```bash
swift test
swift run PomodoroSnapshot /tmp/pomodoro-snapshots
```

`PomodoroSnapshot`은 집중, 휴식, 긴 휴식, 일시정지, 꺼짐 상태의 패널을 PNG로 그리고, 지금 저장소에서 읽은 타이머 상태를 출력해요. 오프스크린 렌더링은 Liquid Glass를 그리지 못해서 스냅샷에서는 반투명 배경으로 대신해요.
