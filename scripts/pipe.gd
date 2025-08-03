extends AnimatableBody2D

var passed := false
@onready var gtg = get_parent().get_parent()

func _process(delta: float) -> void:
	position.x -= 80 * delta # twice what it should be?
	if position.x < -8:
		queue_free()
	if not passed and position.x < 12:
		passed = true
		gtg.score += 1
