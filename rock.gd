extends StaticBody2D
class_name Rock

onready var shape = get_node("shape")
onready var sprite = get_node("sprite")
onready var particles = get_node("particles")

onready var time_to_die = particles.lifetime

const STARTING_HEALTH: float = 10.0
var health: float = STARTING_HEALTH
var death_timer: float = 0.0

func _ready():
	call_deferred("_turn_current_tile_to_dirt")

func _turn_current_tile_to_dirt():
	
	var tilemap: TileMap = Game.current_tile_map()
	var current_tile_position = tilemap.world_to_map(tilemap.to_local(global_position))
	
	# update position and update bitmask too
	var current_tile_value = tilemap.get_cellv(current_tile_position)
	tilemap.set_cellv(current_tile_position, Game.DIRT_TILE_VALUE)
	tilemap.update_bitmask_area(current_tile_position)
	
	# register them as threshed too? :D
	if current_tile_value == Game.WHEAT_TILE_VALUE:
		# Game.register_total_crops_to_thresh(Game.total_crops_to_thresh() - 1)
		pass

func _physics_process(delta):
	death_timer -= delta
	if health <= 0.0 and death_timer <= 0.0:
		queue_free()

func on_collided_with() -> float:
	health = 0.0
	shape.disabled = true
	sprite.visible = false
	particles.emitting = true
	death_timer = time_to_die
	return 10.0
