extends Node

func spawn_cutscene(scene: PackedScene):
	var cutscene_instance = scene.instantiate()
	add_child(cutscene_instance)
