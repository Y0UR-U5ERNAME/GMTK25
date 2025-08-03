extends Node2D

var is_away := true
@onready var target_y := position.y
@onready var btn: Sprite2D = $GTButton
@onready var pb := $PowerButton
@onready var pi: AnimatedSprite2D = $PowerIndicator
@onready var tl := $Toggle/Label
@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

var battery := 1.0: # measured from 0 to 1
	set(x):
		battery = clampf(x, 0, 1)
		if battery == 0: on = false
var on := false:
	set(x):
		on = x
		sub_viewport_container.visible = x
		if on: sub_viewport.add_child(preload("res://scenes/gt_game.tscn").instantiate())
		else: sub_viewport.remove_child(sub_viewport.get_children()[0])
var held_power := 0.0 # how long power button is held for

func _ready():
	pi.play()
	$FBSticker.visible = 1 in GlobalVariables.upgrades

func _on_toggle_clicked() -> void:
	is_away = not is_away
	target_y = 192 if is_away else 192 - 128
	tl.text = "Show GT" if is_away else "Hide GT"
	
func _process(delta: float) -> void:
	if target_y != position.y:
		if target_y < position.y:
			position.y -= 200 * delta
			if target_y > position.y: position.y = target_y
		if target_y > position.y:
			position.y += 200 * delta
			if target_y < position.y: position.y = target_y
	btn.frame = int(Input.is_action_pressed("ui_accept"))
	pb.frame = int(Input.is_action_pressed("power"))
	pi.animation = "off" if not on else "high" if battery > .5 else "mid" if battery > .25 else "low" if battery > .125 else "very_low"
	
	if pb.frame:
		held_power += delta
		if held_power >= 1 and not (not on and battery == 0):
			on = not on
			held_power = 0
	if Input.is_action_just_released("power"):
		held_power = 0
	
	# decrease battery
	if on and Cursor.speed != -1:
		battery -= delta / (240 * 3/8) * (1 + .125 * GlobalVariables.upgrades[2] if 2 in GlobalVariables.upgrades else 1)
