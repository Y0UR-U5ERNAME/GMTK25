extends CharacterBody2D

signal die

const JUMP_VELOCITY = -40.0
@onready var sprite2d := $Sprite2D

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
	velocity.x = 0

	move_and_slide()
	if get_slide_collision_count():
		die.emit()
		velocity.x = 0
	
	sprite2d.flip_h = velocity.y > 0
