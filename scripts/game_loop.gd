extends Scene

var is_moving := false
var time : float = 0 # time elapsed since start of day in seconds
# one game hour = 30 irl seconds, 9am - 5pm = 4 minutes of gametime
var is_paused := false
var to_next_phase : float = 0

@onready var pieces := $Pieces
@onready var conveyor := $Conveyor
@onready var ui_time := $UI/Time
@onready var ui_money := $UI/Money
@onready var energy: TextureProgressBar = $UI/Energy
@onready var boost: TextureProgressBar = $UI/Boost
@onready var dialogue : Dialogue = $UI/Dialogue

static func to_time(t : float) -> String:
	var mins = int(t * 2)
	return str(9 + mins / 60 if mins < 4*60 else mins / 60 - 3) + ":" + ("0" if mins % 60 < 10 else "") + str(mins % 60) + (" AM" if mins < 3*60 else " PM")

func _ready():
	super()
	GlobalVariables.reset_day()
	energy.visible = false
	boost.visible = false
	time = 0
	$UI/Day.text = "DAY " + str(GlobalVariables.day)
	ui_time.text = ["MON", "TUE", "WED", "THU", "FRI (BOSS)"][(GlobalVariables.day - 1) % 5] + " 9:00 AM"
	$UI/Faulty.visible = GlobalVariables.faulty_rate != 0
	$UI/Faulty/CollisionShape2D.disabled = GlobalVariables.faulty_rate == 0
	is_paused = true
	for i in get_children():
		i.process_mode = PROCESS_MODE_DISABLED
	dialogue.visible = true
	if GlobalVariables.day == 1:
		dialogue.switch(
			[
				"Alright, JACK, welcome to your first day at Amir Toys Inc.!",
				"Right, so... how exactly does this work?",
				"Eh, you'll figure it out in no time. All you'll have to do is build some toys and stuff. You'll start off by making some wheels by connecting its two parts",
				"The conveyor belt will move automatically, but you'll be able to work at your own pace if you want to work on the NEXT piece.",
				"Well, that sounds pretty simple. How much am I getting paid again?",
				"You'll be paid daily based on your performance. We'll be expecting more from you the more experienced you are!",
				"Any pay is good, honestly. It's been so hard to find jobs ever since... y'know...",
				"Ha, glad to have you here then. Oh, by the way, we don't offer lunch breaks.",
				"It's fine. All I need to recharge my ENERGY is to play some Spinny Wheel on my new state-of-the-art GameThing (GT)! I get a little BOOST every time my score goes up!",
				"Sorry, but if I catch you playing games on the job or not working hard enough, you'll be FIRED!",
				"...Luckily for you, I only come to check on you guys on FRIDAYS, or as people here like to call them, \"BOSS DAYS\". On other days I have some... \"work\" of my own to do...",
				"Anyways, that thing probably has a limited battery life or something. So you won't be able to play for the whole day even on days when I don't check.",
				"I'll try my best not to get fired! (I'll try my best to hide my game-playing from my boss...)",
				"That's the spirit! You know what they say...",
				"\"All work and no play makes Jack a good worker.\"",
				"Or something like that. I'll let you get to it then!"
			],
			["BOSS", "JACK", "BOSS", "BOSS", "JACK", "BOSS", "JACK", "BOSS", "JACK", "BOSS", "BOSS", "BOSS", "JACK", "BOSS", "BOSS", "BOSS"]
		)
	elif GlobalVariables.day == 2:
		dialogue.switch(
			[
				"You did pretty good for your first day, JACK! Hope you weren't gaming away simultaneously though...",
				"Thanks, I guess...",
				"I'll expect you to work even faster today then! In other news... we've discovered that a small percentage of our parts come out faulty.",
				"Even though they look normal, faulty parts don't connect to any other parts. When two parts don't connect, either one could be faulty.",
				"So I'm hoping you could help us identify them and move them over to the FAULTY section down there. Alright, good luck today!"
			],
			["BOSS", "JACK", "BOSS", "BOSS", "BOSS"]
		)
	elif GlobalVariables.day == 3:
		dialogue.switch(
			[
				"Looks like there's more faulty parts today... As always, keep up the good work!"
			],
			["BOSS"]
		)
	elif GlobalVariables.day == 4:
		dialogue.switch(
			[
				"Hey, new guy...",
				"The name's JACK.",
				"New guy... ya know where them faulty parts end up?",
				"Huh?",
				"They're used to power The Machine...",
				"You mean that thing that made us all into-",
				"Shh... Be careful, else THEY will find out... Don't believe everything they say...",
				"There's been some outages here lately... Hope ya'll still be able to do your work well...",
				"(Luckily, I can still see my GameThing screen in the dark.)"
			],
			["COWORKER", "JACK", "COWORKER", "JACK", "COWORKER", "JACK", "COWORKER", "COWORKER", "JACK"]
		)
	elif GlobalVariables.day % 5 == 0:
		dialogue.switch(
			[
				"Last day of the week! Hope I don't catch you slacking off today! If you do well, maybe you'll get a promotion!"
			],
			["BOSS"]
		)
	elif GlobalVariables.day == 6:
		dialogue.switch(
			[
				"Hey, so... You were supposed to get a promotion and start working on new pieces that use more parts but... Looks like those aren't ready yet.",
				"So instead, I'll just increase your wage. (This will continue every week)"
			],
			["BOSS", "BOSS"]
		)
	elif GlobalVariables.day == 7:
		dialogue.switch(
			[
				"Hey, Jeck...",
				"JACK.",
				"Jeck... Wanna know a secret?",
				"What is it?",
				"Not tellin' ya."
			],
			["COWORKER", "JACK", "COWORKER", "JACK", "COWORKER"]
		)

func _on_dialogue_finished() -> void:
	is_paused = false
	for i in get_children():
		i.process_mode = PROCESS_MODE_INHERIT
	Cursor.speed = INF
	energy.visible = true
	boost.visible = true
	dialogue.queue_free()

func _process(delta: float) -> void:
	ui_money.text = "$%d (+$%d)" % [GlobalVariables.money, max(0, GlobalVariables.pay)]
	if not is_paused:
		energy.value = GlobalVariables.energy
		boost.value = (1 - 1*2/PI * atan(GlobalVariables.since_last_energy_boost/20))
		if GlobalVariables.energy == 0:
			GlobalVariables.fired_message = "Who said you could fall asleep on the job?"
			GlobalVariables.tm.change_scene_to_file("res://scenes/fired.tscn", 11)
		GlobalVariables.energy -= randf() * delta * 0.005 * (.9 if 0 in GlobalVariables.upgrades else 1)
		GlobalVariables.since_last_energy_boost += delta
		ui_time.text = ["MON", "TUE", "WED", "THU", "FRI (BOSS)"][(GlobalVariables.day - 1) % 5] + " " + to_time(time)
		if GlobalVariables.day % 5 == 0 and $GameThing.position.y < 192-24 and $Boss.is_checking:
			GlobalVariables.fired_message = "Thought you were sneaky with your GameThing out while I was checking on you?"
			GlobalVariables.tm.change_scene_to_file("res://scenes/fired.tscn")
			return
		if time >= 240:
			time = 240
			is_paused = true
			if GlobalVariables.pay < 240. / (GlobalVariables.move_time + GlobalVariables.work_time) * GlobalVariables.piece_values[GlobalVariables.target] * .8:
				GlobalVariables.fired_message = "You think this is some kind of game???" if GlobalVariables.pay <= 0 else "Looks like you weren't working hard enough!"
				GlobalVariables.tm.change_scene_to_file("res://scenes/fired.tscn")
			else: GlobalVariables.tm.change_scene_to_file("res://scenes/day_end.tscn")
			return
		time += delta
		to_next_phase -= delta
		if to_next_phase <= 0:
			if not is_moving:
				spawn_pieces(Piece.WHEEL)
				GlobalVariables.play_sound(preload("res://audio/whirr.ogg"), null, "SFX", (2./GlobalVariables.move_time))
			is_moving = not is_moving
			to_next_phase += GlobalVariables.move_time if is_moving else GlobalVariables.work_time
		if is_moving:
			conveyor.region_rect.position.x = fposmod(conveyor.region_rect.position.x - 100 * (2./GlobalVariables.move_time) * delta, 16)

func spawn_pieces(type : int, pos : Vector2 = Vector2(-70, 105)) -> void:
	var parts := Piece.get_parts(type)
	parts.shuffle()
	for p in parts:
		spawn_piece(p, pos + Vector2.UP.rotated(randf() * 2*PI) * Vector2(2, 1) * randf()*40)

func spawn_piece(type : int, pos : Vector2) -> void:
	var piece = GlobalVariables.pieces[type].instantiate()
	piece.position = pos
	#piece.piece_type = type
	pieces.add_child.call_deferred(piece)

func _on_next_button_clicked() -> void:
	if not is_moving:
		to_next_phase = 0
