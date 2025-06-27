extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func pulse():
	animation_player.play("pulse")

	await get_tree().create_timer(2).timeout
	animation_player.stop()
