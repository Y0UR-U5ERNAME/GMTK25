extends Scene

func _ready() -> void:
	super()
	Cursor.speed = -1
	for i in Cursor.get_children():
		if i is Piece: i.queue_free()
	$Reason.text = GlobalVariables.fired_message
	Music.pitch_scale = .5

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		GlobalVariables.reset()
		GlobalVariables.tm.change_scene_to_file("res://scenes/main.tscn")
		Music.pitch_scale = 1.0
