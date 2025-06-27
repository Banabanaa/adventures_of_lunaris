extends Node2D

@onready var ground: StaticBody2D = $Ground
@onready var camera: Camera2D = $Camera2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = $container/StartButton

signal start_game()


func _on_start_button_pressed() -> void:
	start_game.emit()


func disable():
	start_button.disabled = true
	animation_player.play("fade_out")
	await animation_player.animation_finished

	hide()
	ground.disable()
	camera.enabled = false


func enable():
	start_button.disabled = false
	camera.enabled = true
	ground.enable()
	show()
	animation_player.play("fade_in")
