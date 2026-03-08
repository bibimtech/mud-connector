extends Node

enum GamePhase {
	INTRO,
	TOWN,
	FIELD,
	DUNGEON,
	BATTLE,
}

var current_phase: GamePhase = GamePhase.INTRO
var current_town: int = 1
var player_level: int = 1
var player_hp: int = 100
var player_max_hp: int = 100
var player_mp: int = 30
var player_max_mp: int = 30

var terminal: Node = null

func register_terminal(t: Node) -> void:
	terminal = t

func print_line(text: String) -> void:
	if terminal:
		terminal.print_line(text)

func get_available_commands() -> Array:
	match current_phase:
		GamePhase.INTRO:   return ["1", "2", "3", "4", "help"]
		GamePhase.TOWN:    return ["look", "move", "talk", "status", "inventory", "help"]
		GamePhase.FIELD:   return ["look", "move", "enter", "status", "help"]
		GamePhase.DUNGEON: return ["look", "attack", "status", "exit", "help"]
		GamePhase.BATTLE:  return ["attack", "defend", "item", "run", "scan", "status", "help"]
		_: return ["help"]

func handle_command(cmd: String) -> void:
	var parts = cmd.to_lower().split(" ")
	var action = parts[0]
	match current_phase:
		GamePhase.INTRO:   handle_intro(action)
		GamePhase.TOWN:    handle_town(action, parts)
		GamePhase.FIELD:   handle_field(action, parts)
		GamePhase.DUNGEON: handle_dungeon(action, parts)
		GamePhase.BATTLE:  handle_battle(cmd, parts)

# ────────────────────────────────
# INTRO
# ────────────────────────────────
func handle_intro(action: String) -> void:
	match action:
		"1", "2", "3":
			print_line("")
			print_line("[color=#ffff00]접속 중...[/color]")
			await get_tree().create_timer(0.5).timeout
			print_line("[color=#ff4444]오류: 연결이 끊어졌습니다.[/color]")
			await get_tree().create_timer(0.3).timeout
			print_line("[color=#ff4444]리다이렉팅...[/color]")
			await get_tree().create_timer(0.8).timeout
			enter_forgotten_server()
		"4":
			print_line("")
			print_line("[color=#888888]접속을 시도합니다...[/color]")
			await get_tree().create_timer(1.0).timeout
			enter_forgotten_server()
		"help":
			print_line("")
			print_line("[color=#00ffff][ 도움말 ][/color]")
			print_line("  숫자를 입력해서 서버에 접속하세요.")
			print_line("")
		_:
			print_line("[color=#ff4444]알 수 없는 명령입니다. 'help'를 입력하세요.[/color]")

func enter_forgotten_server() -> void:
	print_line("")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("[color=#aaaaaa]서버에 접속했습니다: [/color][color=#ffffff]잊혀진 땅[/color]")
	print_line("")
	await get_tree().create_timer(0.5).timeout
	print_line("[color=#aaaaaa]안녕하세요, 모험가님.[/color]")
	print_line("[color=#aaaaaa]저는 [/color][color=#00ffff]오메가[/color][color=#aaaaaa]입니다. 여정을 도와드릴게요.[/color]")
	print_line("")
	await get_tree().create_timer(0.5).timeout
	current_phase = GamePhase.TOWN
	enter_town(1)

# ────────────────────────────────
# TOWN
# ────────────────────────────────
func enter_town(town_num: int) -> void:
	current_town = town_num
	print_line("")
	print_line("[color=#00ffff][ 마을 " + str(town_num) + ": " + get_town_name(town_num) + " ][/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")
	print_line(get_town_description(town_num))
	print_line("")
	print_line("[color=#555555]'help'를 입력하면 명령어 목록을 볼 수 있습니다.[/color]")
	print_line("")

func handle_town(action: String, parts: Array) -> void:
	match action:
		"look":
			print_line("")
			print_line(get_town_description(current_town))
			print_line("")
		"move":
			if parts.size() > 1:
				handle_move(parts[1])
			else:
				print_line("")
				print_line("[color=#888888]이동 가능: [/color]north (필드)" + (", south (이전 마을)" if current_town > 1 else ""))
				print_line("")
		"talk":
			print_line("")
			print_line("[color=#ffff88]NPC: 모험가여, 북쪽 던전에 몬스터가 출몰하고 있다오.[/color]")
			print_line("")
		"status":
			show_status()
		"inventory":
			print_line("")
			print_line("[color=#00ffff][ 인벤토리 ][/color]")
			print_line("  (비어있음)")
			print_line("")
		"help":
			print_line("")
			print_line("[color=#00ffff][ 마을 명령어 ][/color]")
			print_line("  look        - 주변 살펴보기")
			print_line("  move north  - 북쪽 필드로 이동")
			print_line("  move south  - 이전 마을로 이동")
			print_line("  talk        - NPC와 대화")
			print_line("  status      - 상태 확인")
			print_line("  inventory   - 인벤토리 확인")
			print_line("")
		_:
			print_line("[color=#ff4444]알 수 없는 명령입니다.[/color]")

func handle_move(direction: String) -> void:
	match direction:
		"north":
			print_line("[color=#aaaaaa]북쪽 필드로 이동합니다...[/color]")
			await get_tree().create_timer(0.3).timeout
			current_phase = GamePhase.FIELD
			enter_field()
		"south":
			if current_town > 1:
				print_line("[color=#aaaaaa]이전 마을로 이동합니다...[/color]")
				await get_tree().create_timer(0.3).timeout
				enter_town(current_town - 1)
			else:
				print_line("[color=#ff4444]더 이상 남쪽으로 갈 수 없습니다.[/color]")
		_:
			print_line("[color=#ff4444]그 방향으로는 갈 수 없습니다.[/color]")

# ────────────────────────────────
# FIELD
# ────────────────────────────────
func enter_field() -> void:
	print_line("")
	print_line("[color=#00ffff][ 필드 — 마을 " + str(current_town) + " 외곽 ][/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")
	print_line("넓은 평원이 펼쳐져 있습니다. 멀리 던전 입구가 보입니다.")
	print_line("")
	print_line("[color=#555555]move south (마을) / move north 또는 enter (던전)[/color]")
	print_line("")

func handle_field(action: String, parts: Array) -> void:
	match action:
		"look":
			print_line("")
			print_line("넓은 평원. 남쪽에 마을, 북쪽에 던전 입구가 있습니다.")
			print_line("")
		"move":
			if parts.size() > 1:
				match parts[1]:
					"south":
						print_line("[color=#aaaaaa]마을로 돌아갑니다...[/color]")
						await get_tree().create_timer(0.3).timeout
						current_phase = GamePhase.TOWN
						enter_town(current_town)
					"north", "enter":
						print_line("[color=#aaaaaa]던전으로 진입합니다...[/color]")
						await get_tree().create_timer(0.3).timeout
						current_phase = GamePhase.DUNGEON
						enter_dungeon()
					_:
						print_line("[color=#ff4444]그 방향으로는 갈 수 없습니다.[/color]")
		"enter":
			print_line("[color=#aaaaaa]던전으로 진입합니다...[/color]")
			await get_tree().create_timer(0.3).timeout
			current_phase = GamePhase.DUNGEON
			enter_dungeon()
		"status":
			show_status()
		"help":
			print_line("")
			print_line("[color=#00ffff][ 필드 명령어 ][/color]")
			print_line("  look          - 주변 살펴보기")
			print_line("  move south    - 마을로 이동")
			print_line("  move north    - 던전으로 이동")
			print_line("  enter         - 던전 진입")
			print_line("  status        - 상태 확인")
			print_line("")
		_:
			print_line("[color=#ff4444]알 수 없는 명령입니다.[/color]")

# ────────────────────────────────
# DUNGEON
# ────────────────────────────────
func enter_dungeon() -> void:
	print_line("")
	print_line("[color=#ff4444][ 던전 — 어둠의 동굴 ][/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")
	print_line("차갑고 어두운 동굴. 어디선가 몬스터 소리가 들립니다.")
	print_line("")
	print_line("[color=#555555]'attack'으로 전투 시작, 'exit'으로 나가기[/color]")
	print_line("")

func handle_dungeon(action: String, parts: Array) -> void:
	match action:
		"look":
			print_line("")
			print_line("어두운 동굴. 출구는 남쪽에 있습니다.")
			print_line("")
		"attack":
			start_battle()
		"exit":
			print_line("[color=#aaaaaa]필드로 나갑니다...[/color]")
			await get_tree().create_timer(0.3).timeout
			current_phase = GamePhase.FIELD
			enter_field()
		"status":
			show_status()
		"help":
			print_line("")
			print_line("[color=#00ffff][ 던전 명령어 ][/color]")
			print_line("  look     - 주변 살펴보기")
			print_line("  attack   - 전투 시작")
			print_line("  status   - 상태 확인")
			print_line("  exit     - 던전 나가기")
			print_line("")
		_:
			print_line("[color=#ff4444]알 수 없는 명령입니다.[/color]")

# ────────────────────────────────
# BATTLE
# ────────────────────────────────
var enemy_name: String = "고블린"
var enemy_hp: int = 30
var enemy_max_hp: int = 30

func start_battle() -> void:
	enemy_name = "고블린"
	enemy_hp = 30
	enemy_max_hp = 30
	current_phase = GamePhase.BATTLE
	print_line("")
	print_line("[color=#ff4444][ 전투 시작 ][/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	show_battle_status()

func show_battle_status() -> void:
	print_line("")
	print_line("[color=#ff8888]" + enemy_name + "[/color]  HP: " + str(enemy_hp) + "/" + str(enemy_max_hp))
	print_line("[color=#88ff88]나[/color]           HP: " + str(player_hp) + "/" + str(player_max_hp) + "  MP: " + str(player_mp) + "/" + str(player_max_mp))
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")

func handle_battle(cmd: String, parts: Array) -> void:
	var action = parts[0]

	# 조합 커맨드 처리
	if "+" in cmd:
		handle_combo(cmd)
		return

	match action:
		"attack":
			do_attack(10)
		"defend":
			print_line("[color=#88ffff]방어 자세를 취합니다. (다음 피해 50% 감소)[/color]")
			enemy_attack()
		"scan":
			print_line("[color=#00ffff]" + enemy_name + " 분석 중...[/color]")
			print_line("[color=#aaaaaa]약점: 불 속성 / HP: " + str(enemy_hp) + "/" + str(enemy_max_hp) + "[/color]")
			print_line("")
		"item":
			print_line("[color=#ffff88]사용할 아이템이 없습니다.[/color]")
		"run":
			print_line("[color=#ffff88]전투에서 도망쳤습니다![/color]")
			print_line("")
			current_phase = GamePhase.DUNGEON
		"status":
			show_battle_status()
		"help":
			print_line("")
			print_line("[color=#00ffff][ 전투 명령어 ][/color]")
			print_line("  attack            - 기본 공격 (10 데미지)")
			print_line("  attack + fire     - 불꽃베기 (18 데미지, MP 5)")
			print_line("  scan + attack     - 약점 공격 (15 데미지)")
			print_line("  defend            - 방어")
			print_line("  defend + counter  - 반격 방어")
			print_line("  scan              - 적 분석")
			print_line("  item              - 아이템 사용")
			print_line("  run               - 도망")
			print_line("")
		_:
			print_line("[color=#ff4444]알 수 없는 명령입니다.[/color]")

func handle_combo(cmd: String) -> void:
	var trimmed = cmd.replace(" ", "")
	match trimmed:
		"attack+fire":
			if player_mp >= 5:
				player_mp -= 5
				do_attack(18, "[color=#ff8800]불꽃베기![/color]")
			else:
				print_line("[color=#ff4444]MP가 부족합니다. (필요 MP: 5)[/color]")
		"scan+attack":
			print_line("[color=#00ffff]약점을 분석하고 공격합니다![/color]")
			do_attack(15)
		"defend+counter":
			print_line("[color=#88ffff]반격 자세![/color]")
			do_attack(8, "[color=#ffff00]반격![/color]")
		_:
			print_line("[color=#ff4444]알 수 없는 조합입니다.[/color]")

func do_attack(damage: int, label: String = "") -> void:
	if label != "":
		print_line(label)
	enemy_hp -= damage
	print_line("[color=#ffffff]" + enemy_name + "에게 [/color][color=#ffff00]" + str(damage) + "[/color][color=#ffffff] 데미지![/color]")
	if enemy_hp <= 0:
		battle_win()
	else:
		show_battle_status()
		enemy_attack()

func enemy_attack() -> void:
	var damage = randi_range(5, 12)
	player_hp -= damage
	print_line("[color=#ff4444]" + enemy_name + "의 공격! " + str(damage) + " 데미지![/color]")
	if player_hp <= 0:
		battle_lose()
	else:
		show_battle_status()

func battle_win() -> void:
	print_line("")
	print_line("[color=#ffff00]" + enemy_name + "을(를) 쓰러뜨렸습니다![/color]")
	print_line("[color=#88ff88]경험치 +20[/color]")
	current_phase = GamePhase.DUNGEON
	if player_level < 5:
		player_level += 1
		player_max_hp += 20
		player_hp = player_max_hp
		print_line("[color=#ffff00]★ 레벨 업! Lv." + str(player_level - 1) + " → Lv." + str(player_level) + "[/color]")
	print_line("")

func battle_lose() -> void:
	player_hp = player_max_hp
	print_line("")
	print_line("[color=#ff4444]쓰러졌습니다...[/color]")
	print_line("[color=#888888]마을로 돌아갑니다.[/color]")
	print_line("")
	current_phase = GamePhase.TOWN
	enter_town(current_town)

# ────────────────────────────────
# 공통 유틸
# ────────────────────────────────
func show_status() -> void:
	print_line("")
	print_line("[color=#00ffff][ 상태 ][/color]")
	print_line("  레벨: " + str(player_level))
	print_line("  HP:   " + str(player_hp) + " / " + str(player_max_hp))
	print_line("  MP:   " + str(player_mp) + " / " + str(player_max_mp))
	print_line("")

func get_town_name(n: int) -> String:
	match n:
		1: return "시작의 마을"
		2: return "안개 마을"
		3: return "교차로 마을"
		4: return "황혼의 마을"
		5: return "끝의 마을"
		_: return "알 수 없는 마을"

func get_town_description(n: int) -> String:
	match n:
		1: return "작고 평화로운 마을. 모험의 시작점."
		2: return "짙은 안개가 드리운 마을. 어딘가 이상한 기운이 느껴집니다."
		3: return "여러 길이 교차하는 마을. 낯선 복장의 사람들이 눈에 띕니다."
		4: return "노을빛으로 물든 마을. 벽에 알 수 없는 글자들이 새겨져 있습니다."
		5: return "세상의 끝에 있는 마을. 마왕의 성이 저 멀리 보입니다."
		_: return "알 수 없는 곳."
