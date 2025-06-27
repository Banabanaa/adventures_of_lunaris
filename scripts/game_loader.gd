extends Node

const DATA_PATH = "user://saved_games.dat"

const GAME_TEMPLATE = {
	"spawn_position": Vector2(0, 0)
}

var loaded_game_index: int
var loaded_game: Dictionary
var saved_games: Array

func _ready() -> void:
	saved_games = get_saved_games()

func save_current_game():
	saved_games[loaded_game_index] = loaded_game
	save_games()

func save_games():
	var file := FileAccess.open(DATA_PATH, FileAccess.WRITE)
	if not file:
		var err := FileAccess.get_open_error()
		push_warning("Could not open file: ", error_string(err))
		return false

	file.store_string(JSON.stringify(saved_games, "", false))
	return true

func create_game():
	var time = Time.get_datetime_dict_from_system()
	var game_name = "%02d-%02d-%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute]

	loaded_game = {
		"name": game_name,
		"score": 0
	}

	loaded_game_index = saved_games.size()
	saved_games.push_back(loaded_game)

#func load_game():
	#var saved_games := get_saved_games()
	#print("saved_games ", saved_games)	

func get_saved_games() -> Array:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file: return []
	
	var json_string = file.get_as_text()
	if json_string == "": return []
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data

	print("JSON Parse Error: <", json.get_error_message(), "> in ", json_string, " at line ", json.get_error_line())
	return []

func delete_game(index: int):
	saved_games.remove_at(index)
	save_games()

func rename_game(index: int, new_name: String):
	var game = saved_games[index]
	game.name = new_name
	save_games()
