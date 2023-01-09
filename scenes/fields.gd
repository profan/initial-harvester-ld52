extends Node2D

onready var tile_map = get_node("tile_map")

func _ready():
	
	# haha, well :I
	Game.start_game(tile_map)
	
	# calculate how many crops to thresh left
	var crops_to_thresh = _calculate_amount_of_crops_to_thresh()
	Game.register_total_crops_to_thresh(crops_to_thresh)

func _calculate_amount_of_crops_to_thresh() -> int:
	var tiles_of_wheat_type: int = tile_map.get_used_cells_by_id(Game.WHEAT_TILE_VALUE).size()
	return tiles_of_wheat_type

func _input(event):
	
	if event is InputEventKey:
		if event.is_action_pressed("restart_game"):
			Game.end_game()
			Game.reload_current_scene()
