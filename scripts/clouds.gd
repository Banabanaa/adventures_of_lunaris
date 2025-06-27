extends TileMapLayer

@export var speed: float = 1

func _process(delta: float) -> void:
	position.x += delta * speed
