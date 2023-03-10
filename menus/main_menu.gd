extends Control

onready var start_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/start_game_btn")
onready var how_play_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/how_play_game_btn")
onready var options_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/options_game_btn")
onready var quit_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/quit_game_btn")

func _ready():
	
	# signals
	start_btn.connect("pressed", self, "_on_start_btn_pressed")
	how_play_btn.connect("pressed", self, "_on_how_play_btn_pressed")
	options_btn.connect("pressed", self, "_on_options_btn_pressed")
	quit_btn.connect("pressed", self, "_on_quit_btn_pressed")
	
	if Game.is_web_build():
		quit_btn.visible = false
	
	# set focus on start game button
	start_btn.grab_focus()

func _on_start_btn_pressed():
	Game.switch_to_scene(Game.Scenes.FIELDS)

func _on_how_play_btn_pressed():
	Game.switch_to_scene(Game.Scenes.HOW_MENU)

func _on_options_btn_pressed():
	Game.switch_to_scene(Game.Scenes.OPTIONS_MENU)

func _on_quit_btn_pressed():
	get_tree().quit()
