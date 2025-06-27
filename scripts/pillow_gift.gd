extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_ready: AudioStreamPlayer2D = $AudioReady

func _ready() -> void:
	audio_ready.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("sleep"):
		var sleep_position = Vector2(global_position)
		sleep_position.y -= 8
		animation_player.play("sleep")
		body.sleep(sleep_position)
