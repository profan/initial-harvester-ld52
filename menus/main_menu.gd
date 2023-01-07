extends Control

onready var start_btn = get_node("menu_margin/menu_container/menu_buttons/start_game_btn")
onready var options_btn = get_node("menu_margin/menu_container/menu_buttons/options_game_btn")
onready var quit_btn = get_node("menu_margin/menu_container/menu_buttons/quit_game_btn")

func _ready():
	
	# signals
	start_btn.connect("pressed", self, "_on_start_btn_pressed")
	options_btn.connect("pressed", self, "_on_options_btn_pressed")
	quit_btn.connect("pressed", self, "_on_quit_btn_pressed")

func _on_start_btn_pressed():
	Game.switch_to_scene(Game.Scenes.FIELDS)

func _on_options_btn_pressed():
	pass

func _on_quit_btn_pressed():
	get_tree().quit()
