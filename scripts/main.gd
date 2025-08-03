extends Scene

@onready var conveyor: Sprite2D = $Conveyor

func _on_play_button_clicked() -> void:
	if not TransitionManager.get_node('Node2D').transition:
		GlobalVariables.play_sound(preload("res://audio/swap.wav"))
		TransitionManager.get_node('Node2D').change_scene_to_file("res://scenes/game_loop.tscn", 6)

func _on_quit_button_clicked() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	conveyor.region_rect.position.x = fposmod(conveyor.region_rect.position.x - 100 * delta, 16)
