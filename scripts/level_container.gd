extends Node2D

@export var player_spawn: Node2D
@export var player_light_energy: float = 0
@export var title: String
@onready var animation_finale: AnimationPlayer = $AnimationFinale

@onready var coins: Node2D = $Coins
@onready var slimes: Node2D = $Slimes

signal slimes_updated(amount: int, killed: bool)
signal coins_updated(amount: int, collected: bool)

var coins_left: int
var slimes_left: int

func _ready() -> void:
	slimes_left = slimes.get_children().size()

	for slime in slimes.get_children():
		slime.hide()
		slime.is_dead.connect(_on_slime_killed)

	coins_left = coins.get_children().size()
	for coin in coins.get_children():
		coin.collected.connect(_on_coin_collected)

	initialize_elements.call_deferred()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("collect_coins"):
		for coin in coins.get_children():
			coin.collect()

	if Input.is_action_just_pressed("kill_enemies"):
		for slime in slimes.get_children():
			slime.die()



func initialize_elements():
	slimes_updated.emit(slimes_left, false)
	coins_updated.emit(coins_left, false)

func _on_slime_killed():
	slimes_left -= 1
	slimes_updated.emit(slimes_left, true)


func _on_coin_collected():
	coins_left -= 1
	coins_updated.emit(coins_left, true)

func play_finale():
	animation_finale.play("finale")
