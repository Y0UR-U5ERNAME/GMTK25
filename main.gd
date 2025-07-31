extends Scene

func _on_play_button_clicked() -> void:
	if not TransitionManager.get_node('Node2D').transition:
		GlobalVariables.play_sound(preload("res://audio/swap.wav"))
		TransitionManager.get_node('Node2D').change_scene_to_file("res://scenes/game_loop.tscn", 6)
