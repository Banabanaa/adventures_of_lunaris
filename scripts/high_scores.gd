extends CanvasLayer

@onready var scores_container: GridContainer = %ScoresContainer
@onready var prompt_container: HBoxContainer = %PromptContainer
@onready var alias_edit: LineEdit = %AliasEdit
@onready var save_score_value: Label = %SaveScoreValue

signal save_pressed(alias: String)

func _ready() -> void:
	prompt_container.hide()
	pass

func add_item(player_name: String, score: int):
	var nameLabel = Label.new()
	nameLabel.text = player_name
	
	var scoreLabel = Label.new()
	scoreLabel.text = str(score)
	scoreLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	scores_container.add_child(nameLabel)
	scores_container.add_child(scoreLabel)

func empty():
	for child in scores_container.get_children():
		child.queue_free()

func show_prompt(score):
	save_score_value.text = str(score)
	prompt_container.show()

func hide_prompt():
	prompt_container.hide()

func _on_save_score_button_button_down() -> void:
	save_pressed.emit(alias_edit.text)
