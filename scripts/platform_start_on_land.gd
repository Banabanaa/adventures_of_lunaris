extends Node2D

@export var animation_player: AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player": return

	animation_player.play("move")
