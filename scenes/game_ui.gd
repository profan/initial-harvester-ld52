extends Control

onready var tween: Tween = get_node("tween")

onready var harvester_hp = get_node("margin_container/labels_container/harvester_health")
onready var harvester_time = get_node("margin_container/labels_container/harvester_time")
onready var harvester_crops_harvested = get_node("margin_container/labels_container/harvester_crops_harvested")
onready var harvester_crops_ruined = get_node("margin_container/labels_container/harvester_crops_ruined")

onready var win_label = get_node("margin_container/you_have_won")
onready var restart_label = get_node("margin_container/restart_if_you_want")

func _ready():
	
	# not visible initially :)
	win_label.visible = false
	restart_label.visible = false
	
	# signals
	Game.connect("on_game_won", self, "_on_game_won")
	Game.connect("on_game_lost", self, "_on_game_lost")

func _input(event):
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			Game.end_game()

func _on_game_won():
	
	var crops_threshed_per_second = Game.threshed_crops() / Game.seconds_passed_since_game_start()
	
	if Game.current_game_mode() == Game.GameMode.TimeAttack:
		win_label.text = "YOU HARVESTED: %s CROPS IN %s SECONDS! (%s CROPS/s)" % [Game.threshed_crops(), Game.seconds_passed_since_game_start(), crops_threshed_per_second]
		
	elif Game.current_game_mode() == Game.GameMode.ThreshEmAll:
		win_label.text = "YOU WON, HARVESTING: %s CROPS IN %s SECONDS! (%s CROPS/s)" % [Game.threshed_crops(), Game.seconds_passed_since_game_start(), crops_threshed_per_second]
	
	win_label.visible = true
	restart_label.visible = false

func _on_game_lost():
	
	win_label.visible = false
	restart_label.visible = true
	
	# tween the restart labels rotation
	tween.repeat = true
	tween.interpolate_property(restart_label, "rect_rotation", 0.0, 360.0, tween.TRANS_QUART, tween.EASE_IN_OUT)
	tween.start()

func _process(delta):
	harvester_hp.text = "HEALTH: %s" % Game.harvester_health()
	
	if Game.current_game_mode() == Game.GameMode.TimeAttack:
		harvester_time.text = "TIME LEFT: %ss" % Game.seconds_left_until_game_over()
		
	elif Game.current_game_mode() == Game.GameMode.ThreshEmAll:
		harvester_time.text = "TIME: %ss" % Game.seconds_passed_since_game_start()
		
	harvester_crops_harvested.text = "HARVESTED CROPS: %s" % Game.threshed_crops()
	# harvester_crops_ruined.text = "RUINED CROPS: %s" % Game.ruined_crops()
