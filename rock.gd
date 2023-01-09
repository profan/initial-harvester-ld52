extends StaticBody2D

func _ready():
	call_deferred("_turn_current_tile_to_dirt")

func _turn_current_tile_to_dirt():
	
	var tilemap: TileMap = Game.current_tile_map()
	var current_tile_position = tilemap.world_to_map(tilemap.to_local(global_position))
	
	# update position and update bitmask too
	tilemap.set_cellv(current_tile_position, Game.DIRT_TILE_VALUE)
	tilemap.update_bitmask_area(current_tile_position)
