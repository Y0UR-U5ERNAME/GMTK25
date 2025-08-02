extends MyButton

var page : int
var id : int
var desc : String
var type : int
var price:
	get:
		if price is Array: return price[level]
		return price
var level : int = 1
var line1 : String
var line2 : String

func _ready() -> void:
	super()
	clicked.connect(on_clicked)
	frame_coords.x = type
	$Node2D/Label.text = desc
	line1 = "%s $%d\n%s" % [["Refreshes daily", "One-time", "Level %d" % level][type], price, line2]

func _process(delta: float) -> void:
	super(delta)
	var d = true
	if id in GlobalVariables.upgrades:
		line2 = "Already bought"
	elif price > GlobalVariables.money:
		line2 = "Not enough money"
	else:
		d = false
	if d != disabled: disabled = d
	$Node2D/Label2.text = line1 + "\n" + line2
	$Node2D.position.y = int(is_pressed)

func on_clicked():
	GlobalVariables.money -= price
	GlobalVariables.upgrades[id] = true
	
