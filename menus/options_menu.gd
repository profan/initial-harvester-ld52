extends Control

onready var master_volume_slider = get_node("canvas/menu_margin/menu_container/menu_buttons/master_volume_slider")
onready var music_volume_slider = get_node("canvas/menu_margin/menu_container/menu_buttons/music_volume_slider")
onready var sfx_volume_slider = get_node("canvas/menu_margin/menu_container/menu_buttons/sfx_volume_slider")

onready var back_to_menu_btn = get_node("canvas/menu_margin/menu_container/menu_buttons/back_to_menu_btn")

func _ready():
	
	# set up initial slider values
	master_volume_slider.value = Game.get_master_volume()
	music_volume_slider.value = Game.get_music_volume()
	sfx_volume_slider.value = Game.get_sfx_volume()
	
	# signals for sliders
	master_volume_slider.connect("value_changed", self, "_on_master_volume_slider_value_changed")
	music_volume_slider.connect("value_changed", self, "_on_music_volume_slider_value_changed")
	sfx_volume_slider.connect("value_changed", self, "_on_sfx_volume_slider_value_changed")
	
	# back to menu etc
	back_to_menu_btn.connect("pressed", self, "_on_back_to_menu_pressed")

func _on_master_volume_slider_value_changed(new_value):
	Game.set_master_volume(new_value)
	
func _on_music_volume_slider_value_changed(new_value):
	Game.set_music_volume(new_value)

func _on_sfx_volume_slider_value_changed(new_value):
	Game.set_sfx_volume(new_value)

func _on_back_to_menu_pressed():
	Game.switch_to_scene(Game.Scenes.MAIN_MENU)

func _unhandled_input(event):
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			Game.switch_to_scene(Game.Scenes.MAIN_MENU)
