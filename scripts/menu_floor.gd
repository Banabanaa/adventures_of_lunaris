extends StaticBody2D

@onready var shape_1: CollisionShape2D = $CollisionShape2D
@onready var shape_2: CollisionShape2D = $CollisionShape2D2
@onready var shape_3: CollisionShape2D = $CollisionShape2D3

func disable():
	shape_1.disabled = true
	shape_2.disabled = true
	shape_3.disabled = true


func enable():
	shape_1.disabled = false
	shape_2.disabled = false
	shape_3.disabled = false
