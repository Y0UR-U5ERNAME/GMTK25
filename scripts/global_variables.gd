extends Node

@onready var save_data = null
@onready var tm = TransitionManager.get_node("Node2D")

# global across days
var money := 0
var hi_score := 0
var upgrades = {}
var day := 1

func reset():
	money = 0
	hi_score = 0
	upgrades = {}
	day = 1

# temp
var fired_message : String

const base_piece_values = [10, 10, 20]
var piece_values = [10, 10, 20]

# per day
var pay := 0
var move_time := 2.0
var work_time := 10.0
var faulty_rate := 0.0:
	set(x):
		faulty_rate = x
var target := Piece.WHEEL
var energy := 0.7:
	set(x):
		if x > energy:
			since_last_energy_boost = 0
		energy = clampf(x, 0., 1.)
		if energy < .1 and not tm.transition:
			tm.transition = 10
			tm.rect.material["shader_parameter/size"] = 1
		if energy < .1:
			Music.pitch_scale = energy * 5 + .5
		elif Music.pitch_scale != 1: Music.pitch_scale = 1
var stats := [0, 0, 0, 0, 0, 0, 0, 0]
var since_last_energy_boost := 0.0

func reset_day():
	piece_values = base_piece_values.map(func(x): return x * ((GlobalVariables.day - 1) / 5 + 1))
	
	pay = 0
	move_time = [2, 1.8, 1.6, 1.4, 1.2][day-1] if day <= 5 else 1
	work_time = [10, 7, 5, 4, 3][day - 1] if day <= 5 else 20. / (day + 1)
	faulty_rate = [0, .05, .07, .09, .1][day - 1] if day <= 5 else .1
	target = Piece.WHEEL if day <= 5 else Piece.WHEEL
	energy = [.7, .6, .5, .4, .3][(day - 1)%5] + (.2 if 4 in upgrades else 0)
	stats = [0, 0, 0, 0, 0, 0, 0, 0]
	since_last_energy_boost = 0.0

const pieces = [
	preload("res://scenes/outer_wheel.tscn"),
	preload("res://scenes/inner_wheel.tscn"),
	null
]

func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func save():
	var scene = PackedScene.new()
	scene.pack(get_tree().current_scene)
	#if get_tree().current_scene.name != "Level1":
		#var s = preload("res://collect_sound.tscn").instantiate()
		#get_tree().current_scene.add_child.call_deferred(s)
	save_data = [
		scene,
		get_tree().current_scene.scene_file_path,
		AudioServer.get_bus_volume_linear(0),
		AudioServer.get_bus_volume_linear(1)
	]

func load_save():
	tm.start_dir = 0
	get_tree().change_scene_to_packed(save_data[0])
	AudioServer.set_bus_volume_linear(0, save_data[2])
	AudioServer.set_bus_volume_linear(1, save_data[3])

func play_sound(stream: AudioStream, parent: Node = null):
	var a = AudioStreamPlayer.new()
	a.stream = stream
	a.autoplay = true
	a.bus = "SFX"
	a.process_mode = PROCESS_MODE_ALWAYS
	if parent: parent.add_child.call_deferred(a)
	else: add_child.call_deferred(a)
	a.finished.connect(a.queue_free)
