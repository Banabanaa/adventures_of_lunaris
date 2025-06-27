extends Node2D


@export var levels: Array[PackedScene] = []
var current_level_index: int = -1
var current_level: Node2D

signal level_loaded(level: Node2D, count: int)


func load_level(index: int) -> void:
	hide()
	unload_current_level()

	current_level = levels[index].instantiate()
	current_level_index = index
	add_child(current_level)
	level_loaded.emit(current_level, current_level_index + 1)


func unload_current_level():
	if not current_level: return

	print("unload_current_level ", current_level)
	propagate_call("on_level_unloaded")
	current_level.queue_free()
	current_level = null


func load_next_level():
	load_level(current_level_index + 1)


func reload_level():
	load_level(current_level_index)


func next_level_index():
	current_level_index += 1

	if current_level_index >= levels.size():
		current_level_index = 0

	return current_level_index
