extends Node2D

@export var giftScene: PackedScene
@export_enum("soil", "sand", "clay", "stone") var terrain: String = "soil"
@export var depends_on: Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var spriteDisabled: Sprite2D = $StaticBody2D/SoilDisabled
@onready var audio_locked: AudioStreamPlayer2D = $AudioLocked

@onready var sandEnabled: Sprite2D = $StaticBody2D/SandEnabled
@onready var clayEnabled: Sprite2D = $StaticBody2D/ClayEnabled
@onready var stoneEnabled: Sprite2D = $StaticBody2D/StoneEnabled
@onready var soilDisabled: Sprite2D = $StaticBody2D/SoilDisabled
@onready var sandDisabled: Sprite2D = $StaticBody2D/SandDisabled
@onready var clayDisabled: Sprite2D = $StaticBody2D/ClayDisabled
@onready var stoneDisabled: Sprite2D = $StaticBody2D/StoneDisabled
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_timer: Timer = $ProgressBar/ProgressTimer

var disabled = false
var current_gift: Node2D

func _ready() -> void:
	progress_bar.hide()

	if terrain == "sand":
		sandEnabled.show()
		spriteDisabled = sandDisabled
	elif terrain == "clay":
		clayEnabled.show()
		spriteDisabled = clayDisabled
	elif terrain == "stone":
		stoneEnabled.show()
		spriteDisabled = stoneDisabled

func _on_body_entered(_body: Node2D) -> void:
	if current_gift and current_gift.has_method("respawn"):
		current_gift.respawn()

	if disabled: return

	if depends_on and depends_on.is_locked():
		animationPlayer.play("push")
		audio_locked.play()
		return

	animationPlayer.play("push")

	if not giftScene:
		push_error(self.name, " gift scene not found")
		return

	spawn_gift.call_deferred()


func spawn_gift():
	if current_gift:
		current_gift.destroy()

	disable()

	current_gift = giftScene.instantiate()
	add_child(current_gift)

	if "MAX_DURATION" in current_gift:
		show_progress()

	if current_gift.has_signal("destroyed"):
		current_gift.destroyed.connect(enable, CONNECT_ONE_SHOT)


func enable():
	if not disabled: return

	progress_bar.hide()
	current_gift = null
	disabled = false
	spriteDisabled.hide()
	animationPlayer.play("push")

func disable():
	if disabled: return

	disabled = true
	spriteDisabled.show()

func show_progress():
	progress_bar.max_value = current_gift.MAX_DURATION
	progress_bar.value = current_gift.MAX_DURATION
	progress_bar.show()
	progress_timer.start()

func update_progress():
	progress_bar.value -= 1
