extends Node2D

var locked = true

func is_locked() -> bool:
	return locked

func update_slimes_left(amount: int):
	if amount == 0:
		locked = false
