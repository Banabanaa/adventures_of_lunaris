extends Node2D

@onready var game: Node2D = get_node("/root/Game")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_fluid: AnimatedSprite2D = $"AnimatedFluid"
@onready var sprite_2d: Sprite2D = $Bottle/Sprite2D
@onready var audio_harp: AudioStreamPlayer2D = $AudioHarp

var has_fallen = false
var direction = 1
var offset = 24


func _on_body_entered(body: Node2D) -> void:
	if has_fallen or not body.has_method("drink"):
		return

	has_fallen = true

	if body.global_position.x > global_position.x:
		direction = -1

	scale.x = direction

	if body.has_method("lock"): body.lock()

	animation_player.play("fall")
	await animation_player.animation_finished

	audio_harp.play()
	animated_fluid.show()
	animated_fluid.play("default")
	await animated_fluid.animation_finished

	body.drink(global_position.x + offset * direction)
	await body.has_drank_potion

	animated_fluid.hide()
	animation_player.play("fade_out")
	await animation_player.animation_finished

	queue_free()
	#animation_finished.emit()
