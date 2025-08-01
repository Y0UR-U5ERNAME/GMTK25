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
		frame = int(is_pressed)

func _process(_delta):
	var r := Rect2(global_position - texture.get_size()*scale/2, texture.get_size()*scale/2)
	if r.has_point(Cursor.global_position - Vector2(7, 7)) or r.has_point(Cursor.global_position + Vector2(7, 7)):
		# hover
		if not is_pressed and Input.is_action_just_pressed("left_click"):
			is_pressed = true
		elif is_pressed and Input.is_action_just_released("left_click"):
			is_pressed = false
			clicked.emit()
	else:
		is_pressed = false
