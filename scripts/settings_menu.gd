extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(AudioServer.bus_count)
	pass # Replace with function body.

var is_windowed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if visible: hide()
		else: show()

	if Input.is_action_just_pressed("screen_mode"):
		var window_mode = DisplayServer.window_get_mode()

		if window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		elif window_mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if Input.is_action_just_pressed("toggle_music"):
		var is_mute = AudioServer.is_bus_mute(1)
		AudioServer.set_bus_mute(1, not is_mute)

	if Input.is_action_just_pressed("toggle_sounds"):
		var is_mute = AudioServer.is_bus_mute(2)
		AudioServer.set_bus_mute(2, not is_mute)
