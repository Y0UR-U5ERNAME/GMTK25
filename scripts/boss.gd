extends Sprite2D

var checks_done := 0
var is_blinking := false
var is_checking := false
var is_exiting := false
@onready var warning: Sprite2D = $Warning
@onready var wa: AnimationPlayer = $Warning/AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if GlobalVariables.day % 5 != 0:
		queue_free()
		return
	animation_player.play("RESET")

func _process(delta: float) -> void:
	if not get_parent().is_paused:
		var t = get_parent().time
		if checks_done < GlobalVariables.boss_times.size():
			if not is_blinking and t >= GlobalVariables.boss_times[checks_done] - 3:
				checks_done += 1
				wa.play("blink")
				is_blinking = true
		if is_blinking and t >= GlobalVariables.boss_times[checks_done - 1]:
			is_checking = true
			wa.play("RESET")
			is_blinking = false
			animation_player.play("enter")
		if is_checking and not is_exiting and t >= GlobalVariables.boss_times[checks_done - 1] + 13:
			is_exiting = true
			animation_player.play("exit")
		if is_checking and t >= GlobalVariables.boss_times[checks_done - 1] + 15:# checking lasts 30 mins
			is_exiting = false
			is_checking = false
			animation_player.play("RESET")

func alert():
	GlobalVariables.play_sound(preload("res://audio/alert.wav"))
