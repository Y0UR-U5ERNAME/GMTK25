extends Area2D

var pieces_touching : Array[Piece] = []
var piece_touching : Piece = null

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	piece_touching = pieces_touching.reduce(func(a, b): return a if a.position.y > b.position.y else b) if pieces_touching else null

func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.append(area)

func _on_area_exited(area: Area2D) -> void:
	if area.collision_layer == 0b100:
		pieces_touching.erase(area)
