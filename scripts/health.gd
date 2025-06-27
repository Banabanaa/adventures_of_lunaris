extends Node2D

@export var heart_scene:PackedScene

const HEART_WIDTH = 48

func _ready() -> void:
	for i in range(9):
		var heart:Node2D = heart_scene.instantiate()
		heart.position.x = i * HEART_WIDTH
		heart.scale = Vector2(4, 4)
		add_child(heart)


func player_health_changed(health:int):
	var hearts = get_children()

	for heart in hearts:
		if heart.get_index() < health:
			heart.show()
		else:
			heart.hide()

	var last_heart: Node2D = hearts[health - 1]
	last_heart.pulse()
