extends Node2D

var is_away := true
@onready var target_y := position.y
@onready var tl := $Toggle/Label

func _on_toggle_clicked() -> void:
	is_away = not is_away
	target_y = 192 if is_away else 192 - 128
	tl.text = "TakeOut" if is_away else "PutAway"
	
func _process(delta: float) -> void:
	if target_y != position.y:
		if target_y < position.y:
			position.y -= 200 * delta
			if target_y > position.y: position.y = target_y
		if target_y > position.y:
			position.y += 200 * delta
			if target_y < position.y: position.y = target_y
