extends Control

onready var harvester_time = get_node("margin_container/labels_container/harvester_time")
onready var harvester_crops_harvested = get_node("margin_container/labels_container/harvester_crops_harvested")
onready var harvester_crops_ruined = get_node("margin_container/labels_container/harvester_crops_ruined")

func _ready():
	pass

func _process(delta):
	harvester_time.text = "TIME: %ss" % Game.seconds_passed_since_game_start()
	harvester_crops_harvested.text = "HARVESTED CROPS: %s" % Game.threshed_crops()
	harvester_crops_ruined.text = "RUINED CROPS: %s" % Game.ruined_crops()
