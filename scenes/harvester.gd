extends KinematicBody2D

const STARTING_HEALTH: float = 100.0

onready var t1: Node2D = get_node("thresher/thresher1")
onready var t2: Node2D = get_node("thresher/thresher2")
onready var t3: Node2D = get_node("thresher/thresher3")

onready var p1: Particles2D = get_node("thresher/thresher1/particles1")
onready var p2: Particles2D = get_node("thresher/thresher2/particles2")
onready var p3: Particles2D = get_node("thresher/thresher3/particles3")

onready var e1: Particles2D = get_node("harvester_exhaust_particles")

onready var thresher_shape = get_node("thresher_shape")
onready var harvester_shape = get_node("harvester_shape")
onready var sprite = get_node("sprite")

const MOVEMENT_SPEED: float = 8.0
const FAST_MOVEMENT_MULTIPLIER: float = 2.0
const ROTATION_SPEED: float = 45.0 # degrees per second

# particle stuff
onready var initial_p_lifetime = p1.lifetime

# use this to track if we should be spewing wheat out or not
var last_threshed_threshold: float = 0.5

# tracking threshing, when did we last thresh?
var last_threshed_timer: float = 0.0

# health
var is_destroyed: bool = false
var health: float = STARTING_HEALTH

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
	
	if Game.is_game_started():
		# register initial health
		Game.register_harvester_health_change(health)
	else:
		yield(Game, "on_game_started")
		Game.register_harvester_health_change(health)

func _on_body_entered(other_body):
	pass

func _update_thresher_emitters():
	if is_moving_fast:
		p1.lifetime = initial_p_lifetime / FAST_MOVEMENT_MULTIPLIER
		p2.lifetime = initial_p_lifetime / FAST_MOVEMENT_MULTIPLIER
		p3.lifetime = initial_p_lifetime / FAST_MOVEMENT_MULTIPLIER
	else:
		p1.lifetime = initial_p_lifetime
		p2.lifetime = initial_p_lifetime
		p3.lifetime = initial_p_lifetime

func _input(event):
	if event is InputEvent:
		
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

func _thresh_crop(tile_map: TileMap, tile_position: Vector2, tile_value: int, emitter: Particles2D):
	
	if tile_value == Game.WHEAT_TILE_VALUE:
		tile_map.set_cellv(tile_position, Game.DIRT_TILE_VALUE)
		tile_map.update_bitmask_area(tile_position)
		Game.register_threshed_crop()
		emitter.emitting = true
		_update_thresh_timer()

func _update_thresh_timer():
	last_threshed_timer = last_threshed_threshold

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
	
	_thresh_crop(tile_map, t1_tile_pos, t1_tile_value, p1)
	_thresh_crop(tile_map, t2_tile_pos, t2_tile_value, p2)
	_thresh_crop(tile_map, t3_tile_pos, t3_tile_value, p3)

func _take_damage_from_collision(damage_to_take: float) -> void:
	health -= damage_to_take
	Game.register_harvester_health_change(health)

func _apply_angular_velocity_from_collision(other_object_position: Vector2) -> void:
	var local_velocity_up = velocity.rotated(rotation)
	var angle_to_position = other_object_position.angle_to(local_velocity_up)
	angular_velocity += angle_to_position * 4.0

func _handle_collisions_with_static_bodies():
	
	var objects_collided_with = {}
	
	for i in get_slide_count():
		
		var collision = get_slide_collision(i)
		
		var collided_with_thresher = collision.local_shape == thresher_shape
		var collided_with_body = collision.local_shape == harvester_shape
		
		if (collision.collider is Rock or collision.collider is Fence) and objects_collided_with.has(collision.collider) == false:
			
			objects_collided_with[collision.collider] = true
			print("harvester collided with ", collision.collider.name)
			var damage_taken = collision.collider.on_collided_with()
			
			# double damage taken if we hit it with the thresher
			var actual_damage_taken = damage_taken * 2.0 if collided_with_thresher else damage_taken
			_apply_angular_velocity_from_collision(collision.collider.global_position)
			_take_damage_from_collision(actual_damage_taken)

func _on_harvester_destroyed():
	is_destroyed = true
	e1.emitting = false
	sprite.frame = 3

func _physics_process(delta):
	
	if Game.is_game_started() == false:
		return
	
	if health <= 0.0 and is_destroyed == false:
		_on_harvester_destroyed()
	
	var should_handle_input = is_destroyed == false
	var movement_speed_multiplier = FAST_MOVEMENT_MULTIPLIER if is_moving_fast else 1.0
	var movement_delta: Vector2 = Vector2.ZERO
	var rotation_delta: float = 0.0

	if should_handle_input:

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
	
	if should_handle_input:
		
		if abs(angular_velocity) > 0.5:
			
			if angular_velocity < 0.0:
				sprite.frame = 1
			elif angular_velocity> 0.0:
				sprite.frame = 2
				
		else:
			sprite.frame = 0
	
	var local_velocity_up = velocity.rotated(rotation)
	move_and_slide(local_velocity_up)
	
	# take damage by hitting rocks, etc
	_handle_collisions_with_static_bodies()
	
	# rotation!
	rotation_degrees += angular_velocity # * min(1.0, (velocity.length() / MOVEMENT_SPEED))
	
	# friction
	velocity *= 0.985 * 56.0 * delta
	angular_velocity *= 0.985 * 56.0 * delta
	
	# update thresher emitter state
	_update_thresher_emitters()
	
	# every tick, thresh
	_thresh_shit()
	
	last_threshed_timer -= delta
	
	# if we threshin, particles
	if last_threshed_timer > 0.0:
		e1.emitting = true
	else:
		e1.emitting = false
	
