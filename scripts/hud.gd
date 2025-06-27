extends CanvasLayer


@onready var coins_count: Label = %CoinsCount
@onready var slimes_count: Label = %SlimesCount
@onready var level_count: Label = %LevelCount
@onready var score_value: Label = %ScoreValue
@onready var score_display: Label = $ScoreDisplay
@onready var score_animation: AnimationPlayer = $ScoreDisplay/ScoreAnimation

func update_coins_left(increase: int):
	coins_count.text = str(increase)

func update_slimes_left(increase: int):
	slimes_count.text = str(increase)

func update_level(level: Node2D, count: int):
	level_count.text = "Garden " + str(count) + "\n" + level.title

func update_score(score: int, increase: int, display = true):
	score_value.text = str(score)

	if display:
		var _sign = "+"

		if increase < 0:
			_sign = ""

		score_display.text = _sign + str(increase)
		score_animation.play("pulse")
