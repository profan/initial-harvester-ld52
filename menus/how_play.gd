extends Control

onready var back_to_menu_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/back_to_menu_btn")

func _ready():
	back_to_menu_btn.connect("pressed", self, "_on_back_to_menu_pressed")

func _on_back_to_menu_pressed():
	Game.switch_to_scene(Game.Scenes.MAIN_MENU)

func _unhandled_input(event):
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			Game.switch_to_scene(Game.Scenes.MAIN_MENU)
