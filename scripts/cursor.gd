extends Area2D

var pieces_touching : Array[Piece] = []
var piece_touching : Piece = null
var held_piece : Piece = null
var speed : float = -1

func _process(delta: float) -> void:
	if not GlobalVariables.energy: return
	var mouse_pos := get_global_mouse_position()
	if speed == -1:
		global_position = mouse_pos
	else:
		var dist := mouse_pos - global_position
		if dist.length() < speed * delta:
			global_position = mouse_pos
		else:
			dist = dist.limit_length(speed * delta)
			global_position += dist
		var energy_loss := 0.0
		energy_loss += dist.length() * delta / 10000 # 1/10000 per second*pixel
		energy_loss += (1./1000 if held_piece else 0) * delta
		GlobalVariables.energy -= energy_loss# / GlobalVariables.energy
		speed = Vector2(256, 192).length() * 10 * GlobalVariables.energy**.5
	
	pieces_touching = pieces_touching.filter(func(x): return is_instance_valid(x) and not x.is_attached)
	piece_touching = pieces_touching.reduce(func(a, b): return a if a.position.y > b.position.y else b) if pieces_touching else null
	
	if held_piece and Input.is_action_just_released("left_click"):
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
