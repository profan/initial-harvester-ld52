extends Node2D

onready var tile_map = get_node("tile_map")

func _ready():
	
	# haha, well :I
	Game.start_game(tile_map)

func _input(event):
	
	if event is InputEventKey:
		if event.is_action_pressed("restart_game"):
			Game.reload_current_scene()
