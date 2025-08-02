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

static func to_time(t : float) -> String:
	var mins = int(t * 2)
	return str(9 + mins / 60 if mins < 4*60 else mins / 60 - 3) + ":" + ("0" if mins % 60 < 10 else "") + str(mins % 60) + (" AM" if mins < 3*60 else " PM")

func _ready():
	super()
	time = 230
	$UI/Day.text = "DAY " + str(GlobalVariables.day)
	ui_time.text = ["MON", "TUE", "WED", "THU", "FRI"][(GlobalVariables.day - 1) % 5] + " 9:00 AM"
	$UI/Faulty.visible = GlobalVariables.faulty_rate != 0
	$UI/Faulty/CollisionShape2D.disabled = GlobalVariables.faulty_rate == 0
	dialogue_finished()

func dialogue_finished():
	Cursor.speed = Vector2(256, 192).length() * 10

func _process(delta: float) -> void:
	ui_money.text = "$%d (+$%d)\nEnergy: %f" % [GlobalVariables.money, max(0, GlobalVariables.pay), GlobalVariables.energy]
	if not is_paused:
		if GlobalVariables.energy == 0:
			GlobalVariables.fired_message = "Who said you could fall asleep on the job?"
			GlobalVariables.tm.change_scene_to_file("res://scenes/fired.tscn", 11)
		GlobalVariables.energy -= randf() * delta * 0.005
		ui_time.text = ["MON", "TUE", "WED", "THU", "FRI"][(GlobalVariables.day - 1) % 5] + " " + to_time(time)
		if time >= 240:
			time = 240
			is_paused = true
			if GlobalVariables.pay < 240. / (GlobalVariables.move_time + GlobalVariables.work_time) * Piece.piece_values[GlobalVariables.target] * .8:
				GlobalVariables.fired_message = "Looks like you weren't working hard enough!"
				GlobalVariables.tm.change_scene_to_file("res://scenes/fired.tscn")
			else: GlobalVariables.tm.change_scene_to_file("res://scenes/day_end.tscn")
			return
		time += delta
		to_next_phase -= delta
		if to_next_phase <= 0:
			if not is_moving:
				spawn_pieces(Piece.WHEEL)
			is_moving = not is_moving
			to_next_phase += GlobalVariables.move_time if is_moving else GlobalVariables.work_time
		if is_moving:
			conveyor.region_rect.position.x = fposmod(conveyor.region_rect.position.x - 100 * delta, 16)

func spawn_pieces(type : int, pos : Vector2 = Vector2(-70, 105)) -> void:
	var parts := Piece.get_parts(type)
	parts.shuffle()
	for p in parts:
		spawn_piece(p, pos + Vector2.UP.rotated(randf() * 2*PI) * Vector2(2, 1) * randf()*20)

func spawn_piece(type : int, pos : Vector2) -> void:
	var piece = GlobalVariables.pieces[type].instantiate()
	piece.position = pos
	#piece.piece_type = type
	pieces.add_child.call_deferred(piece)

func _on_next_button_clicked() -> void:
	if not is_moving:
		to_next_phase = 0
