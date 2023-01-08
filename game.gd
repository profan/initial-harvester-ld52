extends Node

class GameState extends Reference:
	
	var _current_ruined_crops: int = 0
	var _current_threshed_crops: int = 0
	var _current_game_timer: float = 0.0
	var _current_tile_map: TileMap
	
	func _init(tile_map: TileMap):
		_current_tile_map = tile_map
	
	func tile_map() -> TileMap:
		return _current_tile_map
	
	func seconds_passed() -> float:
		return _current_game_timer
	
	func crops_threshed() -> int:
		return _current_threshed_crops
		
	func crops_ruined() -> int:
		return _current_ruined_crops
	
	func register_threshed_crop() -> void:
		_current_threshed_crops += 1
		
	func register_ruined_crop() -> void:
		_current_ruined_crops += 1
	
	func tick(delta) -> void:
		_current_game_timer += delta

const Scenes = {
	MAIN_MENU = "res://menus/main_menu.tscn",
	FIELDS = "res://scenes/fields.tscn"
}

var _current_game_state: GameState

func _ready():
	pass

func reload_current_scene():
	SceneSwitcher.goto_scene(SceneSwitcher.current_scene.get_filename())

func switch_to_scene(scene_path: String):
	SceneSwitcher.goto_scene(scene_path)

func current_tile_map() -> TileMap:
	return _current_game_state.tile_map()

func register_threshed_crop() -> void:
	if _current_game_state != null:
		_current_game_state.register_threshed_crop()
		
func register_ruined_crop() -> void:
	if _current_game_state != null:
		_current_game_state.register_ruined_crop()

func threshed_crops() -> int:
	return _current_game_state.crops_threshed()

func ruined_crops() -> int:
	return _current_game_state.crops_ruined()

func seconds_passed_since_game_start() -> int:
	var seconds_passed_since_start = _current_game_state.seconds_passed() if _current_game_state != null else 0.0
	return int(seconds_passed_since_start)

func start_game(current_tile_map: TileMap):
	_current_game_state = GameState.new(current_tile_map)

func end_game():
	_current_game_state = null

func _process(delta):
	
	if _current_game_state != null:
		_current_game_state.tick(delta)
