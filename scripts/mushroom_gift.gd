extends Node2D

@onready var audio_popup: AudioStreamPlayer2D = $AudioPopup

signal destroyed()

const MAX_DURATION: float = 12
const RESPAWN_INTERVAL: float = 0

func _ready() -> void:
	audio_popup.play()

	await get_tree().create_timer(MAX_DURATION).timeout
	destroy()

func destroy():
	destroyed.emit()
	queue_free()

func take_damage(_amount, body: Node2D):
	if body.name == "KillZone":
		destroy()

func respawn():
	get_tree().create_timer(RESPAWN_INTERVAL).timeout.connect(destroy)
