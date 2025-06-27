extends Node2D

@onready var menu: Node2D = $Menu
@onready var levels_manager: Node2D = $LevelsManager
@onready var player: CharacterBody2D = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var player_camera_zoom: AnimationPlayer = $Player/Camera2D/AnimationPlayer
@onready var hud: CanvasLayer = $HUD
@onready var game_over_screen: CanvasLayer = $GameOver
@onready var level_completed: CanvasLayer = $LevelCompleted
@onready var player_light: PointLight2D = $Player/PlayerLight
@onready var audio_game_over: AudioStreamPlayer2D = $AudioGameOver
@onready var audio_level_completed: AudioStreamPlayer2D = $AudioLevelCompleted
@onready var settings_menu: Control = %SettingsMenu
@onready var score_manager: Node2D = $ScoreManager
@onready var instructions: CanvasLayer = $Instructions
@onready var animation_finale: AnimationPlayer = $AnimationFinale

@export var initial_level_index: int = -1

# implementare propagate_call("_on_game_over")



func _ready() -> void:
	if initial_level_index > -1:
		_load_level(initial_level_index)

	player.health_changed.connect(_on_player_health_changed)
	player.has_drank_potion.connect(_on_player_has_drank_potion)
	player.level_completed.connect(_on_level_completed)
	player.died.connect(_on_player_died)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and menu.visible:
		if not score_manager.high_scores.visible:
			_on_start_game()

	if Input.is_action_just_pressed("toggle_zoom"):
		print(player_camera.zoom)
		if player_camera.zoom.x == 2:
			player_camera_zoom.play("zoom_in")
			score_manager.set_normal_clock()
		elif player_camera.zoom.x == 3:
			player_camera_zoom.play("zoom_out")
			score_manager.set_faster_clock()

	if Input.is_action_just_pressed("load_next_level"):
		_load_next_level()

	if Input.is_action_just_pressed("toggle_nightview"):
		if player_light.energy == 0:
			player_light.energy = levels_manager.current_level.player_light_energy
		else:
			player_light.energy = 0

	if Input.is_action_just_pressed("toggle_highscores"):
		if score_manager.high_scores.visible: score_manager.high_scores.hide()
		else: score_manager.high_scores.show()

func _on_start_game() -> void:
	_load_level(0)


func _load_level(index):
	menu.disable()
	levels_manager.load_level(index)


func _on_level_loaded(level: Node2D, count: int) -> void:
	var player_position: Vector2

	if level.player_spawn: player_position = level.player_spawn.position
	else: player_position = level.position

	player_light.energy = level.player_light_energy

	if not player.is_ready.is_connected(_on_player_died):
		player.is_ready.connect(_on_player_ready, CONNECT_ONE_SHOT)

	player.setup_for_new_level(player_position)

	level.coins_updated.connect(_on_coins_updated)
	level.slimes_updated.connect(_on_slimes_updated)

	propagate_call("update_level", [level, count])


func _on_coins_updated(amount: int, collected: bool):
	propagate_call("update_coins_left", [amount])

	if amount == 0:
		var increase = score_manager.prizes.all_coins
		var score = score_manager.update(increase)
		propagate_call("update_score", [score, increase])

		player.gain_health(1)
	elif collected:
		var increase = score_manager.prizes.coin
		var score = score_manager.update(increase)
		propagate_call("update_score", [score, increase])

func _on_slimes_updated(amount: int, killed: bool):
	print("slimes left ", amount)
	propagate_call("update_slimes_left", [amount])

	if killed:
		var increase = score_manager.prizes.slime_killed
		var score = score_manager.update(increase)
		propagate_call("update_score", [score, increase])


func _on_player_ready():
	player.hide()

	player_camera.enabled = true
	player_camera.reset_smoothing()

	await get_tree().create_timer(1).timeout
	level_completed.hide()
	player.show()
	hud.show()
	levels_manager.show()

	score_manager.start_timer()


func _on_level_completed():
	score_manager.stop_timer()

	var increase = score_manager.prizes.level_completed
	var score = score_manager.update(increase)
	propagate_call("update_score", [score, increase])

	var current_level = str(levels_manager.current_level_index + 1)
	level_completed.set_message("Garden " + current_level + " completed!")
	level_completed.show()
	
	#audio_level_completed.play()

	hud.hide()
	_load_next_level()

func _on_player_has_drank_potion():
	propagate_call("player_has_drank_potion")


func _on_player_health_changed(health: int, amount):
	print("player_health_changed: ", health)
	propagate_call("player_health_changed", [health])

	var increase = score_manager.prizes.health_changed
	var score = score_manager.update(increase * amount)
	propagate_call("update_score", [score, increase * amount])


func _load_next_level():
	var next_level_index = levels_manager.next_level_index()

	if not next_level_index:
		game_completed()
		return

	_load_level(next_level_index)

func game_completed():
	player_light.energy = 0
	hud.hide()

	level_completed.set_message("Game finished!")
	level_completed.fade_out()

	var level: Node2D = levels_manager.current_level
	level.play_finale()

	animation_finale.play("finale")
	await animation_finale.animation_finished

	score_manager.prompt_alias()

func _on_player_died(is_game_over: bool):
	await get_tree().create_timer(1).timeout

	if is_game_over:
		game_over()
	else:
		levels_manager.reload_level()

		score_manager.stop_timer()
		var increase = score_manager.prizes.player_died
		var score = score_manager.update(increase)
		propagate_call("update_score", [score, increase])


func game_over():
	audio_game_over.play()
	game_over_screen.show()
	await get_tree().create_timer(1).timeout

	player.hide()
	levels_manager.unload_current_level()
	hud.hide()
	await get_tree().create_timer(1).timeout

	game_over_screen.hide()
	player_camera.enabled = false
	#await get_tree().create_timer(1).timeout

	player_light.energy = 0
	menu.enable()
	player.reset()
	levels_manager.hide()

	score_manager.prompt_alias()


func _on_settings_menu_visibility_changed() -> void:
	if settings_menu.visible:
		score_manager.stop_timer()
	else:
		score_manager.start_timer()

#receive score update every second
func _on_score_clock_update(amount: int, display: bool):
	var score = score_manager.update(amount)
	propagate_call("update_score", [score, amount, display])


func _on_instructions_visibility_changed() -> void:
	if instructions.visible:
		score_manager.stop_timer()
	else:
		score_manager.start_timer()
