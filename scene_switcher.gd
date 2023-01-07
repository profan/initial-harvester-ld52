extends Node

var current_scene

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func goto_scene(path, from_end = false):
	call_deferred("_deferred_goto_scene", path, from_end)

func _deferred_goto_scene(path, from_end):
	
	# Store old name so we can pass it to next one
	var current_scene_name = current_scene.get_filename()

	var old_scene = current_scene
	current_scene.get_parent().remove_child(current_scene)
	current_scene.queue_free()

	# Load new scene
	var s = ResourceLoader.load(path)

	# Instance the new scene
	current_scene = s.instance()
	
	if "from_scene_name" in current_scene:
		if current_scene_name != current_scene.get_filename():
			current_scene.from_scene_name = current_scene_name
		else:
			if "from_scene_name" in old_scene:
				current_scene.from_scene_name = old_scene.from_scene_name

	# HACKUS MAXIMUS
	if from_end: current_scene.set_from_ending_state()

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child(current_scene)
	
	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene(current_scene)
