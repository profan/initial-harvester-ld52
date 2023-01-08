extends Node2D

func _ready():
	
	# haha, well :I
	Game.start_game()

func _input(event):
	
	if event is InputEventKey:
		if event.is_action_pressed("restart_game"):
			Game.reload_current_scene()
