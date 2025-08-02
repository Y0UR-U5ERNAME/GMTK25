extends Scene

@onready var title: Label = $Title
@onready var categories: Label = $Categories
@onready var values: Label = $Values
@onready var moneys: Label = $Moneys
@onready var label: Label = $Label
var progress := 0.0

func _ready() -> void:
	super()
	Cursor.speed = -1
	for i in Cursor.get_children():
		if i is Piece: i.queue_free()
	title.text = "DAY %d COMPLETE!" % GlobalVariables.day
	if GlobalVariables.day == 1:
		categories.text = "Pieces built\nLoose parts\n\nMoney made"
		values.text = "\n".join(GlobalVariables.stats.slice(0, 4, 2).map(str) + ["", "$%d" % GlobalVariables.pay])
		moneys.text = "(+$%d)\n(-$%d)" % GlobalVariables.stats.slice(1, 4, 2)
	else:
		values.text = "\n".join(GlobalVariables.stats.slice(0, 8, 2).map(str) + ["", "$%d" % GlobalVariables.pay])
		moneys.text = "(+$%d)\n(-$%d)\n(+$%d)\n(-$%d)" % GlobalVariables.stats.slice(1, 4, 2)
	
func _process(delta: float) -> void:
	if progress < 12: progress += delta
	
	if progress >= 1: title.visible = true
	
	if 1 < progress and progress < (6 if GlobalVariables.day == 1 else 10):
		categories.max_lines_visible = progress / 2
		values.max_lines_visible = (progress - 1) / 2
		moneys.max_lines_visible = (progress - 1) / 2
	
	if progress >= (6 if GlobalVariables.day == 1 else 10): categories.max_lines_visible = -1
	if progress >= (7 if GlobalVariables.day == 1 else 11):
		values.max_lines_visible = -1
		moneys.max_lines_visible = -1
	
	if progress >= (8 if GlobalVariables.day == 1 else 12):
		label.get_node("AnimationPlayer").current_animation = "blink"
	
	if Input.is_action_just_pressed("left_click"):
		if progress < (8 if GlobalVariables.day == 1 else 12):
			progress = 12
		else:
			GlobalVariables.money += GlobalVariables.pay
			GlobalVariables.tm.change_scene_to_file("res://scenes/shop.tscn")
