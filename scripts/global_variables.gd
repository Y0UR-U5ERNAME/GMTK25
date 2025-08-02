extends Node

@onready var save_data = null
@onready var tm = TransitionManager.get_node("Node2D")

# global across days
var money := 0
var pay := 0
var hi_score := 0
var upgrades = {}

var fired_message : String

# per day
var day := 1
var move_time := 2
var work_time := 10
var faulty_rate := 0
var target := Piece.WHEEL
var energy := 0.7:
	set(x):
		energy = clampf(x, 0., 1.)
		if energy < .1 and not tm.transition:
			tm.transition = 10
			tm.rect.material["shader_parameter/size"] = 1
var stats := [0, 0, 0, 0, 0, 0, 0, 0]

const pieces = [
	preload("res://scenes/outer_wheel.tscn"),
	preload("res://scenes/inner_wheel.tscn"),
	null
]

func _ready():
	randomize()

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
