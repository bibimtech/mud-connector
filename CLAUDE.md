# 잊혀진 서버 (Forgotten Server) — CLAUDE.md

## 프로젝트 개요
- 게임명: 잊혀진 서버 (Forgotten Server)
- 엔진: Godot 4.6.1
- 장르: CLI 스타일 텍스트 RPG
- 플랫폼: PC (Steam 출시 예정)
- 플레이타임: 3~5시간 싱글플레이
- 개발 인원: 1인

## 현재 진행 상태
- [x] 프로젝트 초기 세팅 완료
- [x] 씬 구조 생성 (scenes/terminal.tscn)
- [x] GameState 싱글턴 등록 (scripts/game_state.gd)
- [x] Terminal 스크립트 작성 (scripts/terminal.gd)
- [x] OutputLabel 텍스트 출력 버그 수정 완료
- [x] 창 크기 1280×720 고정 (project.godot)
- [x] 폰트 크기 22px 적용 (OutputLabel, Prompt, InputField)
- [x] 배경색 검은색 설정 (default_clear_color)
- [x] 엔터 후 포커스 복귀 구현 (call_deferred grab_focus)
- [x] 전체 게임 흐름 구현: INTRO → TOWN(1~5) → FIELD → DUNGEON → BATTLE
- [x] 커맨드 조합 전투 시스템 (attack+fire, scan+attack, defend+counter)
- [x] 커맨드 히스토리 (↑↓), 자동완성 (Tab)

## 프로젝트 구조
mud-connector/
├── scenes/
│   └── terminal.tscn        메인 씬 (Control 루트)
├── scripts/
│   ├── terminal.gd          UI 입출력 담당
│   └── game_state.gd        게임 로직 싱글턴 (AutoLoad: GameState)
├── forgotten_server_GDD_v0.3.md  게임 디자인 문서
└── CLAUDE.md

## 씬 노드 구조
Terminal (Control) — Full Rect, scripts/terminal.gd 연결
└── VBoxContainer — Full Rect
    ├── ScrollContainer — size_flags_vertical: Expand+Fill
    │   └── OutputLabel (RichTextLabel) — bbcode_enabled, font 22px
    └── InputContainer (HBoxContainer)
        ├── Prompt (Label) — text: "> ", font 22px
        └── InputField (LineEdit) — font 22px
            ※ text_submitted 시그널은 씬 파일이 아닌 terminal.gd _ready에서 connect

## 주요 구현 세부사항
- **Enter 처리**: _input에서 처리하지 않고 LineEdit.text_submitted 시그널로 처리
  - 이유: _input에서 accept_event() 시 macOS 한글 IME 조합 완료가 차단됨
- **포커스 복귀**: submit_command 내 input_field.call_deferred("grab_focus")
- **한글 IME**: macOS + Godot 4 조합의 알려진 미해결 이슈. 조합 중 엔터 시 조합만 완료되고 제출은 한 번 더 눌러야 함. 엔진 레벨 한계로 완전 해결 불가
- **배경색**: project.godot rendering.environment/defaults/default_clear_color = Color(0,0,0,1)

## 게임 구조
- GamePhase: INTRO → TOWN(1~5) → FIELD → DUNGEON → BATTLE
- 마을 5개, 마을 간 필드, 필드 안 던전
- 커맨드 조합 전투 (attack + fire 등)
- 알파/오메가 캐릭터, 4종 엔딩 분기 (GDD v0.3 참조)

## 기술 스택
- 엔진: Godot 4.6.1
- 언어: GDScript
- Steam 배포: GodotSteam 플러그인 (추후)
- 다국어: JSON 기반 키-값 (추후)

## 다음 할 일
1. 게임 전체 흐름 테스트 (서버목록 → 접속 → 마을1~5 → 전투 → 엔딩)
2. 기본 UI 레이아웃 정리
3. GDD v0.3 기반 스토리 힌트 시스템 구현 (마을별 힌트, 알파 개발 일지, 미완성 프로젝트 폴더)
4. NPC 대사 다양화
5. 마왕 최종전 및 4종 엔딩 구현
