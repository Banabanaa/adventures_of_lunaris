extends CanvasLayer

@onready var label: Label = $Control/Label
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

@export var message: String


func _ready() -> void:
	set_message(message)

func set_message(text):
	label.text = text

func fade_out():
	animation_player.play("fade_out")
