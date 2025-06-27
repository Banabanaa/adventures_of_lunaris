extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal collected

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		collect()

func collect():
	animation_player.play("pickup")
	collected.emit()

	await animation_player.animation_finished
	queue_free()
