extends GameState

var _prev_state: GameState

func enter(prev_state: GameState):
	super(prev_state)
	_prev_state = prev_state

func process_input(_event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel"):
		return _prev_state
