extends MyButton

var page : int
var id : int
var desc : String
var type : int
var real_price
var price:
	get:
		if real_price is Array:
			if level + 1 < real_price.size(): return real_price[level]
			return real_price[level - 1]
		return real_price
var level : int = 0
var line1 : String
var line2 : String

func _ready() -> void:
	super()
	clicked.connect(on_clicked)
	frame_coords.x = type
	$Node2D/Icon.texture = load("res://graphics/icon%d.png" % id)
	$Node2D/Label.text = desc
	level = 0 if id not in GlobalVariables.upgrades else GlobalVariables.upgrades[id]

func _process(delta: float) -> void:
	if page != get_parent().page:
		visible = false
	else:
		visible = true
		super(delta)
	var lvl = ""
	if type == 2:
		lvl = "Lvl %d > Lvl %d" % [level, level+1]
	var d = true
	if id >= 5:
		line2 = "Coming soon"
	elif type == 2 and id in GlobalVariables.upgrades and GlobalVariables.upgrades[id] == real_price.size():
		line2 = "Maxed out"
		lvl = "Lvl %d" % [level]
	elif type != 2 and id in GlobalVariables.upgrades:
		line2 = "Already bought"
	elif price > GlobalVariables.money:
		line2 = "Not enough money"
	else:
		line2 = ""
		d = false
	if d != disabled: disabled = d
	line1 = "$%d\n%s" % [price, ["Refreshes daily", "Permanent", lvl][type]]
	$Node2D/Label2.text = line1 + "\n" + line2
	$Node2D.position.y = frame_coords.y * 3

func on_clicked():
	GlobalVariables.money -= price
	if id in GlobalVariables.upgrades:
		GlobalVariables.upgrades[id] += 1
	else:
		GlobalVariables.upgrades[id] = 1
	level += 1
	GlobalVariables.play_sound(preload("res://audio/kaching.wav"))
	
