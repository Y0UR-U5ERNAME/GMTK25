extends Scene

enum {
	DAILY,
	ONETIME,
	UPGRADEABLE
}

var upgrades = [
	[0, "ENERGY DRINK\nDecreases energy loss from working the next day (-10%)", DAILY, 500],
	[1, "SPINNY WHEEL STICKER\nIncreases energy gain from playing Spinny Wheel (+5%)", ONETIME, 300],
	[2, "LONGER BATTERY LIFE\nIncreases GameThing battery life (+16.7%)", UPGRADEABLE, [1000, 2000, 5000, 10000]],
	[3, "COFFEE MAKER\nDecreases energy loss from working (permanent) (-5%)", ONETIME, 1000],
	[4, "BIG BREAKFAST\nIncreases starting energy the next day (+30%)", DAILY, 1500],
	[5, "EASY PEASY (SPINNY WHEEL)\nIncreases gap between obstacles in Spinny Wheel (+8px)", UPGRADEABLE, [500, 1000, 2000]],
	[6, "11 AM ALARM\nReceive a boost of energy at 11 AM the next day (+10%)", DAILY, 2000],
	[7, "1 PM ALARM\nReceive a boost of energy at 1 PM the next day (+10%)", DAILY, 5000],
	[8, "3 PM ALARM\nReceive a boost of energy at 3 PM the next day (+10%)", DAILY, 10000],
	[9, "GAMETHING 2\nNow with a joystick and a longer battery life! Backwards-compatible with GT", ONETIME, 5000],
	[10, "WHEELY ROAD\nGame that provides more energy than Spinny Wheel. Only compatible with GT2", ONETIME, 2000]
]
var page := 0
var num_pages := 1

func _ready() -> void:
	super()
	
	for i in upgrades:
		if i[0] in GlobalVariables.upgrades and i[2] == DAILY:
			GlobalVariables.upgrades.erase(i[0])
	upgrades = upgrades.filter(func(x): return x[0] not in GlobalVariables.upgrades or (GlobalVariables.upgrades[x[0]] != len(x[3]) if x[2] == UPGRADEABLE else false))
	num_pages = ceil(upgrades.size() / 3.)
	if num_pages <= 1:
		$Left.queue_free()
		$Right.queue_free()
	var c := 0
	for i in upgrades:
		var si = preload("res://scenes/shop_item.tscn").instantiate()
		si.position = Vector2(128, 40 + 16 + c%3*40)
		si.page = c / 3
		si.id = i[0]
		si.desc = i[1]
		si.type = i[2]
		si.real_price = i[3]
		add_child(si)
		c += 1

func _process(delta: float) -> void:
	$Label.text = "$%d" % GlobalVariables.money
	$Label2.text = "Page %d of %d" % [page + 1, num_pages]

func _on_my_button_clicked() -> void:
	Music.stream = preload("res://audio/assembly_line-010.mp3")
	Music.play()
	GlobalVariables.day += 1
	GlobalVariables.tm.change_scene_to_file("res://scenes/game_loop.tscn")

func _on_left_clicked() -> void:
	page = posmod(page - 1, num_pages)

func _on_right_clicked() -> void:
	page = posmod(page + 1, num_pages)
