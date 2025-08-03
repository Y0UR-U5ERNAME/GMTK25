extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var pieces_touching : Array[Piece] = []
var piece_touching : Piece = null
var held_piece : Piece = null
var held_for = 0.0
var speed : float = -1
var state : int = POINT:
	set(x):
		state = x
		sprite_2d.frame = state

enum {
	GRAB,
	PINCH,
	POINT
}

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	mouse_pos = Vector2(clampf(mouse_pos.x, 0, 256), clampf(mouse_pos.y, 0, 192))
	if speed == -1:
		global_position = mouse_pos
		state = POINT
	else:
		state = PINCH if held_piece else GRAB
		var dist := mouse_pos - global_position
		if dist.length() < speed * delta:
			global_position = mouse_pos
		else:
			dist = dist.limit_length(speed * delta)
			global_position += dist
		var energy_loss := 0.0
		energy_loss += dist.length() * delta / 5000
		energy_loss += (1./500 if held_piece else 0) * delta
		GlobalVariables.energy -= energy_loss * (1 - (.1 if 0 in GlobalVariables.upgrades else 0) - (.05 if 3 in GlobalVariables.upgrades else 0))
		speed = Vector2(256, 192).length() * 7 * GlobalVariables.energy * (1 - .5*2/PI * atan(GlobalVariables.since_last_energy_boost/20))
	
	if not GlobalVariables.energy:
		return
	
	pieces_touching = pieces_touching.filter(func(x): return is_instance_valid(x) and not x.is_attached)
	piece_touching = pieces_touching.reduce(func(a, b): return a if a.position.y > b.position.y else b) if pieces_touching else null
	
	if held_piece:
		held_for += delta
	else:
		held_for = 0.0
	
	if held_piece and (Input.is_action_just_released("left_click") or GlobalVariables.energy < .25 and held_for >= GlobalVariables.energy * 4):
		GlobalVariables.play_sound(preload("res://audio/btn_up.ogg"))
		held_piece.reparent(get_tree().current_scene.get_node("Pieces"))
		if piece_touching and piece_touching != held_piece:
			Piece.combine(held_piece, piece_touching)
		held_piece = null
	if held_piece: held_piece.is_held = true
	#print(pieces_touching, piece_touching)

func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.erase(area)
