extends Node

class GameState extends Reference:
	
	var _current_game_timer: float = 0.0
	
	func seconds_passed() -> float:
		return _current_game_timer
	
	func tick(delta) -> void:
		_current_game_timer += delta

const Scenes = {
	MAIN_MENU = "res://menus/main_menu.tscn",
	FIELDS = "res://scenes/fields.tscn"
}

var _current_game_state: GameState

func _ready():
	pass

func switch_to_scene(scene_path: String):
	SceneSwitcher.goto_scene(scene_path)

func seconds_passed_since_game_start() -> int:
	var seconds_passed_since_start = _current_game_state.seconds_passed() if _current_game_state != null else 0.0
	return int(seconds_passed_since_start)

func start_game():
	_current_game_state = GameState.new()

func end_game():
	_current_game_state = null

func _process(delta):
	
	if _current_game_state != null:
		_current_game_state.tick(delta)
