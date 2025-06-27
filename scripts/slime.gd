extends Node2D

const SPEED = 60

var direction: int = 1
var is_alive: bool = true

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dead_sound: AudioStreamPlayer2D = $DeadSound

@export var gift_scene: PackedScene

signal is_dead()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_alive:
		return

	if ray_cast_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	
	if ray_cast_left.is_colliding():
		direction = 1
		sprite.flip_h = false

	position.x += direction * SPEED * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_alive:
		return

	var bodyName = body.get_name()

	match bodyName:
		"Player":
			body.take_damage(1, self)
			sprite.play("hurt")
			await sprite.animation_finished
			sprite.play("default")

		"Mushroom":
			body.destroy()
			die()

		_: print("unhandled body entered slime: ", bodyName)

func player_has_drank_potion():
	show()

func die():
	show()
	is_alive = false
	is_dead.emit()
	dead_sound.play()

	sprite.play("melt")
	await sprite.animation_finished
	
	if gift_scene:
		spawn_object(gift_scene)

	queue_free()

func spawn_object(scene: PackedScene):
	var gift = scene.instantiate()
	gift.position = global_position
	get_parent().add_child(gift)
