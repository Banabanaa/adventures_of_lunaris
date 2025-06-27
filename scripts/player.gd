extends CharacterBody2D

signal is_ready()
signal health_changed(health:int, amount: bool)
signal died(game_over:bool)
signal level_completed()
signal has_drank_potion()
signal is_done_walking_to()

@onready var game:Node2D = get_node("/root/Game")
@onready var animated_sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_ahead:RayCast2D = $RayCastAhead
@onready var ray_cast_behind: RayCast2D = $RayCastBehind
@onready var ray_cast_above:RayCast2D = $RayCastAbove
@onready var audio_hurt:AudioStreamPlayer2D = $AudioStreamHurt
@onready var audio_jump:AudioStreamPlayer2D = $AudioStreamJump
@onready var audio_gain_health: AudioStreamPlayer2D = $AudioGainHealth
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var audio_licking: AudioStreamPlayer2D = $AudioLicking
@onready var paw_collision_right: CollisionShape2D = $PawCollisionRight
@onready var paw_collision_left: CollisionShape2D = $PawCollisionLeft
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var jump_buffer_timer: Timer = $BufferJumpTimer

# health
const MAX_HEALTH = 9
const INITIAL_HEALTH = 5
var health = INITIAL_HEALTH

# movement params
const acceleration: float = 360
const ground_friction: float = 0.65
const air_friction: float = 0.65
const jump_velocity: float = 280.0
const jump_factor: float = 0.25
const double_jump_factor: float = 0.88
var max_speed: float = 136

# player state
var is_alive:bool = true
var is_vulnerable:bool = true
var is_locked:bool = false
var is_sleeping:bool = false
var walking_to = 0

var has_double_jumped:bool = false
var currentSpeed:float = 0.0

func _ready() -> void:
	health_changed.emit.call_deferred(health, 0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("drink_potion"):
		has_drank_potion.emit()

func _physics_process(delta:float) -> void:
	if is_sleeping or not is_alive:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var was_on_floor = is_on_floor()

	var direction: float = 0

	if is_locked:
		animated_sprite.stop()
	else:
		# Handle inputs
		if Input.is_action_pressed("jump") and jump_buffer_timer.is_stopped():
			if is_on_floor() or not coyote_jump_timer.is_stopped():
				has_double_jumped = false
				jump()
				was_on_floor = false
			elif ray_cast_ahead.is_colliding():
				double_jump()
			else:
				pass

		direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		turn_right()
	elif direction < 0:
		turn_left();

	if direction and not ray_cast_ahead.is_colliding():
		velocity.x = move_toward(velocity.x, max_speed * direction, delta * acceleration)
	else:
		if is_on_floor():
			velocity.x *= ground_friction
		else:
			velocity.x *= air_friction
	
	currentSpeed = abs(velocity.x)

	# Play animations
	if is_on_floor():
		if ray_cast_above.is_colliding():
			animated_sprite.play("crouch")
		else:
			if direction == 0 and walking_to == 0:
				if not paw():
					animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

	if walking_to:
		position.x = move_toward(position.x, walking_to, 1)

		if position.x == walking_to:
			walking_to = 0
			animated_sprite.stop()
			is_done_walking_to.emit()

	move_and_slide()

	var just_left_ledge = was_on_floor and not is_on_floor()
	if just_left_ledge:
		coyote_jump_timer.start()
		#print("coyote start")

func turn_right():
	animated_sprite.flip_h = false
	ray_cast_ahead.scale.x = 1
	ray_cast_behind.scale.x = 1
	ray_cast_above.scale.x = 1

func turn_left():
	animated_sprite.flip_h = true
	ray_cast_ahead.scale.x = -1
	ray_cast_behind.scale.x = -1
	ray_cast_above.scale.x = -1


func calculate_jump_velocity() -> float:
	return - jump_velocity - jump_factor * currentSpeed

func jump():
	coyote_jump_timer.stop()
	jump_buffer_timer.start()

	velocity.y = calculate_jump_velocity()
	#print(velocity.y)
	audio_jump.pitch_scale = 1
	audio_jump.play()
	
func double_jump():
	if has_double_jumped:
		return

	jump_buffer_timer.start()
	has_double_jumped = true
	velocity.y = calculate_jump_velocity() * double_jump_factor
	audio_jump.pitch_scale = 1.5
	audio_jump.play()

func lock(seconds = 0):
	is_locked = true
	animated_sprite.stop()

	if seconds:
		get_tree().create_timer(seconds).timeout.connect(unlock)

func unlock():
	is_locked = false


func gain_health(amount: int):
	if health == MAX_HEALTH: return

	health = min(health + amount, MAX_HEALTH)
	health_changed.emit(health, amount)
	audio_gain_health.play()

func take_damage(damage, source: Node2D):
	if not is_alive: return
	if not is_vulnerable: return

	var reset_level = (source.name == "KillZone")

	print("damaged ", damage, " by ", source.name)
	audio_hurt.play()

	health = max(health - damage, 0)
	health_changed.emit(health, -1)
	
	if health == 0:
		# game over
		lock()
		die(true)
		return

	if reset_level:
		# player fell
		die(false)
	else:
		makeInvulnerable(1)

func die(game_over:bool = false):
	if not is_alive: return

	is_alive = false
	animation_player.play("die")
	died.emit(game_over)

func makeInvulnerable(seconds):
	is_vulnerable = false
	animation_player.play("invulnerable")
	get_tree().create_timer(seconds).timeout.connect(_on_vulnerable_timer_timeout)

func _on_vulnerable_timer_timeout() -> void:
	is_vulnerable = true
	animation_player.stop()

func sleep(sleep_position:Vector2):
	if is_sleeping: return

	is_sleeping = true
	position = sleep_position

	animated_sprite.play("sleep")
	await animated_sprite.animation_finished
	level_completed.emit()


func resume():
	animated_sprite.stop()
	is_sleeping = false

	if not is_alive:
		is_alive = true
		animation_player.stop()

	turn_right()
	show()

func reset():
	position = Vector2(0, 0)
	resume()
	health = INITIAL_HEALTH
	health_changed.emit(INITIAL_HEALTH, 0)
	unlock()


func setup_for_new_level(new_position: Vector2):
	position = new_position
	hide()
	await get_tree().create_timer(1).timeout

	resume()
	is_ready.emit()


func drink(target_x):
	walking_to = target_x

	if walking_to > position.x:
		turn_right()
	else:
		turn_left()

	await is_done_walking_to

	audio_licking.play()	
	#lock other animations
	is_sleeping = true

	animated_sprite.play("drink")
	await animated_sprite.animation_finished

	is_sleeping = false
	unlock()
	has_drank_potion.emit()


func paw() -> bool:
	paw_collision_left.disabled = true
	paw_collision_right.disabled = true

	# can't paw when there's something behind
	if ray_cast_ahead.is_colliding() and ray_cast_behind.is_colliding():
		return false

	if not Input.is_action_pressed("paw"):
		return false
	
	animated_sprite.play("paw")

	if animated_sprite.flip_h:
		# is turned left
		paw_collision_left.disabled = false
	else:
		# is turned right
		paw_collision_right.disabled = false

	return true
