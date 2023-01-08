extends Control

onready var harvester_time = get_node("margin_container/labels_container/harvester_time")

func _ready():
	pass

func _process(delta):
	harvester_time.text = "TIME: %ss" % Game.seconds_passed_since_game_start()
