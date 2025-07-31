extends Sprite2D
class_name MyButton

signal button_down
signal button_up
signal clicked
var is_pressed := false:
	set(x):
		is_pressed = x
		if x: button_down.emit()
		else: button_up.emit()

func _process(_delta):
	if Rect2(global_position - texture.get_size()*scale/2, global_position + texture.get_size()*scale/2).has_point(Cursor.global_position):
		# hover
		if not is_pressed and Input.is_action_just_pressed("left_click"):
			is_pressed = true
		elif is_pressed and Input.is_action_just_released("left_click"):
			is_pressed = false
			clicked.emit()
	else:
		is_pressed = false
