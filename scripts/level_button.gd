extends Button

@export var levelScene: PackedScene

signal level_button_pressed(level: Node2D)

func _on_pressed() -> void:
	if not levelScene:
		print(self.name, " level not found")
		return

	var instance = levelScene.instantiate()
	level_button_pressed.emit(instance)
