extends Node

const DIRT_TILE_VALUE = 6
const WHEAT_TILE_VALUE = 174

signal on_game_started
signal on_game_ended

class GameState extends Reference:
	
	var _current_harvester_health: float = 0.0
	var _current_ruined_crops: int = 0
	var _current_threshed_crops: int = 0
	var _current_game_timer: float = 0.0
	var _current_tile_map: TileMap
	
	func _init(tile_map: TileMap):
		_current_tile_map = tile_map
	
	func harvester_health() -> float:
		return _current_harvester_health

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
	
	func register_harvester_health(new_health: float) -> void:
		_current_harvester_health = new_health
	
	func tick(delta) -> void:
		_current_game_timer += delta

const Scenes = {
	MAIN_MENU = "res://menus/main_menu.tscn",
	FIELDS = "res://scenes/fields.tscn"
}

var _current_game_state: GameState

func _ready():
	pass

func is_game_started():
	return _current_game_state != null

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

func register_harvester_health_change(new_health: float) -> void:
	if _current_game_state != null:
		_current_game_state.register_harvester_health(new_health)

func harvester_health() -> float:
	return _current_game_state.harvester_health()

func threshed_crops() -> int:
	return _current_game_state.crops_threshed()

func ruined_crops() -> int:
	return _current_game_state.crops_ruined()

func seconds_passed_since_game_start() -> int:
	var seconds_passed_since_start = _current_game_state.seconds_passed() if _current_game_state != null else 0.0
	return int(seconds_passed_since_start)

func start_game(current_tile_map: TileMap):
	_current_game_state = GameState.new(current_tile_map)
	emit_signal("on_game_started")

func end_game():
	_current_game_state = null
	emit_signal("on_game_ended")

func _process(delta):
	
	if _current_game_state != null:
		_current_game_state.tick(delta)
