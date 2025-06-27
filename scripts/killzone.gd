extends Area2D

@onready var game: Node2D = get_node("/root/Game")
@onready var timer: Timer = $Timer

func _ready() -> void:
	name = "KillZone"

func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage"): return

	print("killzone body entered :", body)
	body.take_damage(1, self)
