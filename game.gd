extends Node

const Scenes = {
	MAIN_MENU = "res://menus/main_menu.tscn",
	FIELDS = "res://scenes/fields.tscn"
}

func _ready():
	pass

func switch_to_scene(scene_path: String):
	SceneSwitcher.goto_scene(scene_path)
