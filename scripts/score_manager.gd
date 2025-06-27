extends Node2D

@onready var timer: Timer = $ScoreTimer
@export var high_scores: CanvasLayer

signal update_clock(amount: int, display: bool)

const HIGHSCORES_FILENAME = "user://highscores.dat"
const DEFAULT_HIGHSCORES = {"BANA": 123456}

var player_score: int = 0

var prizes = {
	"clock": -1,
	"coin": 10,
	"all_coins": 100,
	"slime_killed": 100,
	"level_completed": 1000,
	"health_changed": 100,
	"player_died": -1000
}

func _ready() -> void:
	high_scores.visibility_changed.connect(update_list)
	high_scores.save_pressed.connect(save_score)

	#test score prompt
	#player_score = 250
	#prompt_alias.call_deferred()

func update_list():
	if not visible: return

	var scores: Dictionary = load_highscores()

	high_scores.empty()

	for player_name in scores:
		high_scores.add_item(player_name, scores[player_name])


func start_timer():
	timer.start()

func stop_timer():
	timer.stop()

func set_normal_clock():
	timer.wait_time = 1

func set_faster_clock():
	timer.wait_time = 0.5

func _on_score_timer_timeout() -> void:
	update_clock.emit(prizes.clock, false)

func load_highscores() -> Dictionary:
	#return DEFAULT_HIGHSCORES.duplicate()

	var file := FileAccess.open(HIGHSCORES_FILENAME, FileAccess.READ)

	if not file: return DEFAULT_HIGHSCORES.duplicate()

	var json_string = file.get_as_text()

	if json_string == "": return DEFAULT_HIGHSCORES.duplicate()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error == OK:
		return json.data

	print("JSON Parse Error: <", json.get_error_message(), "> in ", json_string, " at line ", json.get_error_line())
	return {}

func save_highscore(player_name: String) -> bool:
	var scores: Dictionary = load_highscores()

	if scores.has(player_name) and scores[player_name] > player_score:
		print("trying to record a lower score")
		return false

	scores = insert_sorted_score(scores, player_name)

	var file := FileAccess.open(HIGHSCORES_FILENAME, FileAccess.WRITE)
	if not file:
		var err := FileAccess.get_open_error()
		push_warning("Could not open file: ", error_string(err))
		return false

	file.store_string(JSON.stringify(scores, "", false))
	return true

func insert_sorted_score(scores: Dictionary, player_name) -> Dictionary:
	var result: Dictionary = {}
	var inserted: bool = false

	for alias: String in scores:
		#skip self
		if alias == player_name: continue

		var current_score = int(scores[alias])

		if player_score > current_score and not inserted:
			result[player_name] = player_score
			inserted = true

		result[alias] = current_score

	if not inserted:
		result[player_name] = player_score

	return result

func prompt_alias():
	high_scores.show()

	if not player_score > 0: return

	high_scores.show_prompt(player_score)

func save_score(alias: String):
	alias = alias.trim_prefix(" ").trim_suffix(" ")

	if alias == "": return

	if save_highscore(alias):
		high_scores.hide_prompt()

	update_list.call_deferred()

func update(increase):
	player_score = max(0, player_score + increase)
	return player_score
