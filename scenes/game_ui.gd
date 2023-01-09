extends Control

const HINT_TIME: float = 2.0

onready var tween: Tween = get_node("tween")

onready var harvester_hp = get_node("margin_container/labels_container/harvester_health")
onready var harvester_time = get_node("margin_container/labels_container/harvester_time")
onready var harvester_crops_harvested = get_node("margin_container/labels_container/harvester_crops_harvested")
onready var harvester_threshing_velocity = get_node("margin_container/labels_container/harvester_threshing_velocity")
onready var harvester_crops_ruined = get_node("margin_container/labels_container/harvester_crops_ruined")

onready var hint1 = get_node("margin_container/hints/hint1")
onready var hint2 = get_node("margin_container/hints/hint2")
onready var hint3 = get_node("margin_container/hints/hint3")

onready var win_label = get_node("margin_container/you_have_won")
onready var restart_label = get_node("margin_container/restart_if_you_want")

func _ready():
	
	# not visible initially
	hint1.visible = false
	hint2.visible = false
	hint3.visible = false
	
	# not visible initially :)
	win_label.visible = false
	restart_label.visible = false
	
	# signals
	Game.connect("on_game_won", self, "_on_game_won")
	Game.connect("on_game_lost", self, "_on_game_lost")
	
	if Game.is_game_started():
		_display_hints_on_game_start()
	else:
		yield(Game, "on_game_started")
		_display_hints_on_game_start()

func _display_hints_on_game_start():
	
	hint1.visible = true
	hint1.modulate.a = 0.0
	
	tween.interpolate_property(hint1, "modulate:a", hint1.modulate.a, 1.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(hint1, "modulate:a", 1.0, 0.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT, HINT_TIME / 2.0)
	tween.start()
	
	hint1.text = "YOU'VE GOT %s SECONDS UNTIL ALL YOUR CROPS GO BAD!" % [Game.seconds_left_until_game_over()]
	yield(tween, "tween_all_completed")
	hint1.visible = false
	
	hint2.visible = true
	hint2.modulate.a = 0.0
	
	tween.interpolate_property(hint2, "modulate:a", hint2.modulate.a, 1.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(hint2, "modulate:a", 1.0, 0.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT, HINT_TIME / 2.0)
	tween.start()
	
	hint2.text = "... AND REMEMBER, ROCKS ARE NO GOOD FOR YOUR MACHINE!"
	yield(tween, "tween_all_completed")
	hint2.visible = false
	
	hint3.visible = true
	hint3.modulate.a = 0.0

	tween.interpolate_property(hint3, "modulate:a", hint3.modulate.a, 1.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(hint3, "modulate:a", 1.0, 0.0, HINT_TIME / 2.0, Tween.TRANS_QUART, Tween.EASE_IN_OUT, HINT_TIME / 2.0)
	tween.start()

	hint3.text = "GOOD LUCK, AND MAINTAIN THRESHING VELOCITY"
	yield(tween, "tween_all_completed")
	hint3.visible = false
	

func _input(event):
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			Game.end_game()

func _on_game_won():
	
	var crops_threshed_per_second = float(Game.threshed_crops()) / float(Game.seconds_passed_since_game_start())
	
	if Game.current_game_mode() == Game.GameMode.TimeAttack:
		win_label.text = "YOU HARVESTED: %s CROPS IN %s SECONDS! (%.2f CROPS/s)" % [Game.threshed_crops(), Game.seconds_passed_since_game_start(), crops_threshed_per_second]
		
	elif Game.current_game_mode() == Game.GameMode.ThreshEmAll:
		win_label.text = "YOU WON, HARVESTING: %s CROPS IN %s SECONDS! (%.2f CROPS/s)" % [Game.threshed_crops(), Game.seconds_passed_since_game_start(), crops_threshed_per_second]
	
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
	
	if Game.is_game_started() == false:
		return
	
	var seconds_since_game_start = Game.seconds_passed_since_game_start()
	var crops_threshed_per_second = float(Game.threshed_crops()) / float(seconds_since_game_start) if seconds_since_game_start > 0 else 0.0
	
	harvester_hp.text = "HEALTH: %s" % Game.harvester_health()
	
	if Game.current_game_mode() == Game.GameMode.TimeAttack:
		harvester_time.text = "TIME LEFT: %ss" % Game.seconds_left_until_game_over()
		
	elif Game.current_game_mode() == Game.GameMode.ThreshEmAll:
		harvester_time.text = "TIME: %ss" % Game.seconds_passed_since_game_start()
		
	harvester_crops_harvested.text = "HARVESTED CROPS: %s" % Game.threshed_crops()
	harvester_threshing_velocity.text = "THRESHING VELOCITY: %.2f CROPS/s" % crops_threshed_per_second
	# harvester_crops_ruined.text = "RUINED CROPS: %s" % Game.ruined_crops()
