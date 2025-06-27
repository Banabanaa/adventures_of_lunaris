extends Node

@export var animation_player: AnimationPlayer
@export var target_scene: Node

# emitted when a state is done and wants to switch to another
signal done(new_state: GameState)

# avoid unused signal warning
func _done(): done.emit()

func _ready() -> void:
	if target_scene:
		target_scene.visible = false

func enter(_prev_state: GameState):
	print("enter " + name)
	if animation_player and animation_player.has_animation("enter"):
		animation_player.play("enter")
	elif target_scene:
		target_scene.visible = true

func exit(_next_state: GameState):
	print("exit ", name)
	if animation_player and animation_player.has_animation("exit"):
		animation_player.play("exit")
	elif target_scene:
		target_scene.visible = false

func process_input(_event: InputEvent) -> GameState:
	return null

func process_frame(_delta: float) -> GameState:
	return null
