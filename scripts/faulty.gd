extends Area2D

var piece : Piece = null

func _on_area_entered(area: Area2D) -> void:
	piece = area

func _on_area_exited(area: Area2D) -> void:
	piece = null

func _process(_delta):
	if piece and Input.is_action_just_released("left_click"):
		piece.payout_faulty()
