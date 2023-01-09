extends StaticBody2D
class_name Fence

onready var shape = get_node("shape")
onready var sprite = get_node("sprite")
onready var particles = get_node("particles")

onready var time_to_die = particles.lifetime

var health: float = 10.0
var death_timer: float = 0.0

func _ready():
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
