extends KinematicBody2D

onready var t1 = get_node("thresher/thresher1")
onready var t2 = get_node("thresher/thresher2")
onready var t3 = get_node("thresher/thresher3")

onready var thresher_shape = get_node("thresher_shape")
onready var harvester_shape = get_node("harvester_shape")
onready var sprite = get_node("sprite")

const MOVEMENT_SPEED: float = 16.0
const FAST_MOVEMENT_MULTIPLIER: float = 2.0
const ROTATION_SPEED: float = 45.0 # degrees per second

# physics
var velocity: Vector2 = Vector2.ZERO
var current_wheel_angle: float = 0.0
var angular_velocity: float = 0.0

# input state
var is_moving_forwards: bool = false
var is_moving_backwards: bool = false
var is_moving_fast: bool = false

var is_turning_left: bool = false
var is_turning_right: bool = false

func _ready():
	pass

func _input(event):
	if event is InputEventKey:
		
		if event.is_action_pressed("move_forwards"):
			is_moving_forwards = true
		elif event.is_action_released("move_forwards"):
			is_moving_forwards = false
			
		if event.is_action_pressed("move_backwards"):
			is_moving_backwards = true
		elif event.is_action_released("move_backwards"):
			is_moving_backwards = false
			
		if event.is_action_pressed("move_fast"):
			is_moving_fast = true
		elif event.is_action_released("move_fast"):
			is_moving_fast = false
			
		if event.is_action_pressed("turn_left"):
			is_turning_left = true
		elif event.is_action_released("turn_left"):
			is_turning_left = false
			
		if event.is_action_pressed("turn_right"):
			is_turning_right = true
		elif event.is_action_released("turn_right"):
			is_turning_right = false

func _thresh_crop(tile_map: TileMap, tile_position: Vector2, tile_value: int):
	
	var DIRT_TILE_VALUE = 6
	var WHEAT_TILE_VALUE = 174
	
	if tile_value == WHEAT_TILE_VALUE:
		tile_map.set_cellv(tile_position, DIRT_TILE_VALUE)
		tile_map.update_bitmask_area(tile_position)
		Game.register_threshed_crop()

func _thresh_shit():
	
	var tile_map: TileMap = Game.current_tile_map()
	
	var t1_local_world_pos = tile_map.to_local(t1.global_position)
	var t2_local_world_pos = tile_map.to_local(t2.global_position)
	var t3_local_world_pos = tile_map.to_local(t3.global_position)
	
	var t1_tile_pos = tile_map.world_to_map(t1_local_world_pos)
	var t2_tile_pos = tile_map.world_to_map(t2_local_world_pos)
	var t3_tile_pos = tile_map.world_to_map(t3_local_world_pos)
	
	var t1_tile_value = tile_map.get_cellv(t1_tile_pos)
	var t2_tile_value = tile_map.get_cellv(t2_tile_pos)
	var t3_tile_value = tile_map.get_cellv(t3_tile_pos)
	
	_thresh_crop(tile_map, t1_tile_pos, t1_tile_value)
	_thresh_crop(tile_map, t2_tile_pos, t2_tile_value)
	_thresh_crop(tile_map, t3_tile_pos, t3_tile_value)
	

func _physics_process(delta):
	
	var movement_speed_multiplier = FAST_MOVEMENT_MULTIPLIER if is_moving_fast else 1.0
	var movement_delta: Vector2 = Vector2.ZERO
	var rotation_delta: float = 0.0
	
	if is_moving_forwards:
		movement_delta += Vector2.UP
	
	if is_moving_backwards:
		movement_delta -= Vector2.UP

	if is_moving_forwards or is_moving_backwards:
		
		if is_turning_left:
			rotation_delta -= deg2rad(ROTATION_SPEED) * min(1.0, (velocity.length() / MOVEMENT_SPEED))
		
		if is_turning_right:
			rotation_delta += deg2rad(ROTATION_SPEED) * min(1.0, (velocity.length() / MOVEMENT_SPEED))
	
	velocity += movement_delta * MOVEMENT_SPEED * movement_speed_multiplier
	angular_velocity += rotation_delta * 0.25
	
	if abs(angular_velocity) > 0.5:
		
		if angular_velocity < 0.0:
			sprite.frame = 1
		elif angular_velocity> 0.0:
			sprite.frame = 2
			
	else:
		sprite.frame = 0
	
	var local_velocity_up = velocity.rotated(rotation)
	move_and_slide(local_velocity_up)
	
	# rotation!
	rotation_degrees += angular_velocity # * min(1.0, (velocity.length() / MOVEMENT_SPEED))
	
	# friction
	velocity *= 0.985 * 56.0 * delta
	angular_velocity *= 0.985 * 56.0 * delta
	
	# every tick, thresh
	_thresh_shit()
	
