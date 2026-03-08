extends Control

var command_history: Array = []
var history_index: int = -1

@onready var output_label: RichTextLabel = $VBoxContainer/ScrollContainer/OutputLabel
@onready var input_field: LineEdit = $VBoxContainer/InputContainer/InputField
@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	GameState.register_terminal(self)
	input_field.text_submitted.connect(_on_text_submitted)
	input_field.grab_focus()

	await get_tree().process_frame
	await get_tree().process_frame

	print_line("")
	print_line("[color=#00ff00]MUD CONNECTOR v0.1[/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")
	print_line("[color=#aaaaaa]접속 중...[/color]")
	await get_tree().create_timer(1.0).timeout
	show_server_list()

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_UP:
			navigate_history(1)
		KEY_DOWN:
			navigate_history(-1)
		KEY_TAB:
			autocomplete()
			accept_event()

func _on_text_submitted(text: String) -> void:
	submit_command(text)

func navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return
	history_index = clamp(history_index + direction, 0, command_history.size() - 1)
	input_field.text = command_history[command_history.size() - 1 - history_index]
	input_field.caret_column = input_field.text.length()

func autocomplete() -> void:
	var current = input_field.text.strip_edges()
	var available = GameState.get_available_commands()
	var matches = available.filter(func(cmd): return cmd.begins_with(current))
	if matches.size() == 1:
		input_field.text = matches[0]
		input_field.caret_column = input_field.text.length()
	elif matches.size() > 1:
		print_line("[color=#555555]" + "  ".join(matches) + "[/color]")

func print_line(text: String) -> void:
	output_label.append_text(text + "\n")
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func submit_command(text: String) -> void:
	var cmd = text.strip_edges()
	if cmd.is_empty():
		return
	command_history.append(cmd)
	history_index = -1
	print_line("[color=#00ff00]> " + cmd + "[/color]")
	input_field.clear()
	input_field.call_deferred("grab_focus")
	GameState.handle_command(cmd)

func show_server_list() -> void:
	print_line("[color=#00ffff][ 서버 목록 ][/color]")
	print_line("[color=#555555]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/color]")
	print_line("")
	print_line("  1. 드래곤의 땅    [color=#888888](판타지)[/color]  ............  접속자 42")
	print_line("  2. 강호의 바람    [color=#888888](무협)[/color]    ............  접속자 17")
	print_line("  3. 스타포지       [color=#888888](SF)[/color]      ............  접속자 8")
	print_line("  4. [color=#555555]???            (알 수 없음)  ............  접속자 0[/color]")
	print_line("")
	print_line("접속할 서버 번호를 입력하세요.")
	print_line("")
