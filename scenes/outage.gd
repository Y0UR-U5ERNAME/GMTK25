extends ColorRect

var num_done := 0
var is_out := false

func _ready() -> void:
	if GlobalVariables.day < 4:
		queue_free()
		return

func _process(delta: float) -> void:
	if not get_parent().is_paused:
		var t = get_parent().time
		if num_done < GlobalVariables.outage_times.size():
			if not is_out and t >= GlobalVariables.outage_times[num_done]:
				num_done += 1
				GlobalVariables.play_sound(preload("res://audio/powerdown.wav"))
				visible = true
				is_out = true
		if is_out and t >= GlobalVariables.outage_times[num_done-1] + 7.5:
			GlobalVariables.play_sound(preload("res://audio/powerup.wav"))
			is_out = false
			visible = false
