extends Area2D

var pieces_touching : Array[Piece] = []
var piece_touching : Piece = null
var held_piece : Piece = null

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	pieces_touching = pieces_touching.filter(func(x): return is_instance_valid(x) and not x.is_attached)
	piece_touching = pieces_touching.reduce(func(a, b): return a if a.position.y > b.position.y else b) if pieces_touching else null
	
	if held_piece and Input.is_action_just_released("left_click"):
		held_piece.reparent(get_tree().current_scene.get_node("Pieces"))
		if piece_touching and piece_touching != held_piece:
			Piece.combine(held_piece, piece_touching)
		held_piece = null
	#print(pieces_touching, piece_touching)

func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.erase(area)
