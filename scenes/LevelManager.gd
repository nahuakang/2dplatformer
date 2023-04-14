extends Node

export(Array, PackedScene) var level_scenes

var current_level_index = 0

func change_level(level_index: int) -> void:
	current_level_index = level_index

	# Wrap around if max level reached
	if (current_level_index >= level_scenes.size()):
		current_level_index = 0

	get_tree().change_scene(level_scenes[current_level_index].resource_path)

func increment_level() -> void:
	change_level(current_level_index + 1)
