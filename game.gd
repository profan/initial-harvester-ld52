extends Node

# ui
const FADE_TIME = 0.75

# game
const DIRT_TILE_VALUE = 6
const WHEAT_TILE_VALUE = 174
const TIME_ATTACK_TIME_LIMIT = 120

onready var tween = get_node("tween")
onready var fader = get_node("canvas/fader")

onready var music_player = get_node("music_player")
onready var sfx_player = get_node("sfx_player")

signal on_fade_completed

signal on_game_started
signal on_game_ended

signal on_game_won
signal on_game_lost

enum GameMode {
	TimeAttack,
	ThreshEmAll
}

class GameState extends Reference:
	
	signal on_game_won
	signal on_game_lost
	
	var _game_mode = GameMode.TimeAttack
	
	# win states
	var _was_game_won: bool = false
	var _was_game_lost: bool = false
	
	# goals
	var _total_crops_to_thresh: int = 0
	var _time_attack_time_limit: int = TIME_ATTACK_TIME_LIMIT
	
	# state
	var _current_harvester_health: float = 0.0
	var _current_ruined_crops: int = 0
	var _current_threshed_crops: int = 0
	var _current_game_timer: float = 0.0
	var _current_tile_map: TileMap
	
	func _init(tile_map: TileMap):
		_current_tile_map = tile_map
	
	func is_game_over() -> bool:
		return _was_game_won or _was_game_lost
	
	func game_mode():
		return _game_mode
	
	func harvester_health() -> float:
		return _current_harvester_health

	func tile_map() -> TileMap:
		return _current_tile_map
	
	func seconds_passed() -> float:
		return _current_game_timer
	
	func time_attack_time_limit() -> int:
		return _time_attack_time_limit
	
	func total_crops_to_thresh() -> int:
		return _total_crops_to_thresh
	
	func crops_threshed() -> int:
		return _current_threshed_crops
		
	func crops_ruined() -> int:
		return _current_ruined_crops
	
	func register_total_crops_to_thresh(crops_to_thresh: int) -> void:
		_total_crops_to_thresh = crops_to_thresh
	
	func register_threshed_crop() -> void:
		_current_threshed_crops += 1
		_check_if_time_attack_won()
		_check_if_thresh_em_all_won()
	
	func register_ruined_crop() -> void:
		_current_ruined_crops += 1
	
	func register_harvester_health(new_health: float) -> void:
		_current_harvester_health = new_health
		if _current_harvester_health <= 0.0 and is_game_over() == false:
			_was_game_lost = true
			emit_signal("on_game_lost")
	
	func _check_if_time_attack_won() -> void:
		if _game_mode == GameMode.TimeAttack:
			if _current_game_timer >= _time_attack_time_limit and is_game_over() == false:
				_was_game_won = true
				emit_signal("on_game_won")
	
	func _check_if_thresh_em_all_won() -> void:
		if _game_mode == GameMode.ThreshEmAll:
			if _current_threshed_crops >= _total_crops_to_thresh and is_game_over() == false:
				_was_game_won = true
				emit_signal("on_game_won")
	
	func tick(delta) -> void:
		
		# return early if game was lost, not ticking game anymore
		if _was_game_won or _was_game_lost:
			return
			
		_check_if_time_attack_won()
		_current_game_timer += delta

const Scenes = {
	MAIN_MENU = "res://menus/main_menu.tscn",
	OPTIONS_MENU = "res://menus/options_menu.tscn",
	HOW_MENU = "res://menus/how_play.tscn",
	FIELDS = "res://scenes/fields.tscn"
}

const Sounds = {
	CLICK = "CLICK"
}

const Samples = {
	CLICK = preload("res://raw/sound/menu_click.wav")
}

# game state
var _current_game_state: GameState

func _ready():
	
	# volume shit
	var initial_master_volume = 0.5
	var initial_music_volume = 1.0
	var initial_sfx_volume = 1.0
	
	# set up sfx/music player volumes appropriately
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(initial_master_volume))
	music_player.volume_db = linear2db(initial_music_volume)
	sfx_player.volume_db = linear2db(initial_sfx_volume)

func _fade_in():
	tween.interpolate_property(fader, "color:a", fader.color.a, 0.0, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	emit_signal("on_fade_completed")

func _fade_out():
	tween.interpolate_property(fader, "color:a", fader.color.a, 1.0, FADE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	emit_signal("on_fade_completed")

func _on_game_won():
	emit_signal("on_game_won")

func _on_game_lost():
	emit_signal("on_game_lost")

func get_master_volume() -> float:
	var master_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	return db2linear(master_volume_db)

func get_sfx_volume() -> float:
	return db2linear(sfx_player.volume_db)

func get_music_volume() -> float:
	return db2linear(music_player.volume_db)

func set_master_volume(new_linear_volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(new_linear_volume))

func set_sfx_volume(new_linear_volume: float) -> void:
	sfx_player.volume_db = linear2db(new_linear_volume)

func set_music_volume(new_linear_volume: float) -> void:
	music_player.volume_db = linear2db(new_linear_volume)

func play_sound(sound_name) -> void:
	var found_sound = Samples[sound_name]
	sfx_player.stream = found_sound
	sfx_player.play()

func is_game_started():
	return _current_game_state != null

func reload_current_scene():
	switch_to_scene(SceneSwitcher.current_scene.get_filename())

func switch_to_scene(scene_path: String):
	_fade_out()
	yield(self, "on_fade_completed")
	SceneSwitcher.goto_scene(scene_path)
	_fade_in()

func current_tile_map() -> TileMap:
	return _current_game_state.tile_map()

func register_total_crops_to_thresh(crops_to_thresh: int) -> void:
	if _current_game_state != null:
		_current_game_state.register_total_crops_to_thresh(crops_to_thresh)

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

func total_crops_to_thresh() -> int:
	return _current_game_state.total_crops_to_thresh()

func threshed_crops() -> int:
	return _current_game_state.crops_threshed()

func ruined_crops() -> int:
	return _current_game_state.crops_ruined()

func seconds_left_until_game_over() -> int:
	return _current_game_state.time_attack_time_limit() - seconds_passed_since_game_start()

func seconds_passed_since_game_start() -> int:
	var seconds_passed_since_start = _current_game_state.seconds_passed() if _current_game_state != null else 0.0
	return int(seconds_passed_since_start)

func current_game_mode():
	return _current_game_state.game_mode()

func start_game(current_tile_map: TileMap):
	_current_game_state = GameState.new(current_tile_map)
	_current_game_state.connect("on_game_won", self, "_on_game_won")
	_current_game_state.connect("on_game_lost", self, "_on_game_lost")
	emit_signal("on_game_started")

func end_game():
	emit_signal("on_game_ended")
	_current_game_state = null
	Game.switch_to_scene(Game.Scenes.MAIN_MENU)

func _process(delta):
	
	if _current_game_state != null:
		_current_game_state.tick(delta)
