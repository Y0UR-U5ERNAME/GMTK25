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
		if Cursor.speed != -1:
			GlobalVariables.energy += atan(gtg.score / 5.) * 2/PI * 0.05 * (1.05 if 1 in GlobalVariables.upgrades else 1)
