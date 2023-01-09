extends StaticBody2D
class_name Rock

onready var shape = get_node("shape")

const STARTING_HEALTH: float = 10.0

var health: float = STARTING_HEALTH

func _ready():
	call_deferred("_turn_current_tile_to_dirt")

func _turn_current_tile_to_dirt():
	
	var tilemap: TileMap = Game.current_tile_map()
	var current_tile_position = tilemap.world_to_map(tilemap.to_local(global_position))
	
	# update position and update bitmask too
	tilemap.set_cellv(current_tile_position, Game.DIRT_TILE_VALUE)
	tilemap.update_bitmask_area(current_tile_position)

func _physics_process(delta):
	if health <= 0.0:
		queue_free()

func on_collided_with() -> float:
	health = 0.0
	shape.disabled = true
	return 10.0
