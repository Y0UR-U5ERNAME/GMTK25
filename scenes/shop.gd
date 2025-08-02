extends Scene

enum {
	DAILY,
	ONETIME,
	UPGRADEABLE
}

var upgrades = [
	[0, "ENERGY DRINK\nDecreases energy loss from working", DAILY, 500],
	[1, "SPINNY WHEEL STICKER\nIncreases energy gained from playing", ONETIME, 500],
	[1, "SPINNY WHEEL STICKER\nIncreases energy gained from playing", ONETIME, 500]
]
var page := 0
var num_pages := 1

func _ready() -> void:
	super()	
	# filter out bought upgrades
	num_pages = ceil(upgrades.size() / 3.)
	var c := 0
	for i in upgrades:
		var si = preload("res://scenes/shop_item.tscn").instantiate()
		si.position = Vector2(128, 48 + 16 + c%3*40)
		si.page = c / 3
		si.id = i[0]
		si.desc = i[1]
		si.type = i[2]
		si.price = i[3]
		add_child(si)
		c += 1

func _process(delta: float) -> void:
	$Label.text = "$%d" % GlobalVariables.money
