extends GameState

@export var settings_state: GameState
@export var load_state: GameState
@export var play_state: GameState

func _ready() -> void:
	target_scene.start_game.connect(done.emit.bind(play_state))
	target_scene.load_game.connect(done.emit.bind(load_state))

func enter(prev_state: GameState):
	if target_scene.enabled:
		super(prev_state)
	else:
		target_scene.enable()

func exit(next_state: GameState):
	if next_state == play_state:
		target_scene.disable()

func process_input(_event: InputEvent) -> GameState:
	if Input.is_action_just_pressed("ui_cancel"):
		return settings_state
	
	return null
