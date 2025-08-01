extends Node2D

@onready var rect = $ColorRect
enum {
	NO_TRANSITION,
	TRANSITION_IN,
	TRANSITION_OUT,
	TRANSITION_CIRCLE_IN,
	TRANSITION_CIRCLE_OUT,
	TRANSITION_OPEN_H,
	TRANSITION_CLOSE_H,
	TRANSITION_OPEN_V,
	TRANSITION_CLOSE_V
}
var transition:
	set(t):
		transition = t
		rect.material["shader_parameter/mode"] = 0 if t < TRANSITION_OPEN_H else 1 if t < TRANSITION_OPEN_V else 2
		rect.visible = t != NO_TRANSITION
		
const SPEED = 700
const CIRCLE_SPEED = 500
var to_scene = null
@onready var curr_scene = get_tree().current_scene.scene_file_path
@onready var rect_size = rect.size
var start_dir = 1

func start(type: int):
	if not curr_scene: curr_scene = GlobalVariables.save_data[1]
	visible = true
	transition = type
	rect.material["shader_parameter/size"] = 0
	if get_tree().current_scene.name.substr(0, 5) != "Level":
		rect.material["shader_parameter/pos"] = Vector2(0, rect_size.y/2)
		#rect.material["shader_parameter/pos"] = rect_size/2
	get_tree().paused = false

func _process(delta):
	match transition:
		NO_TRANSITION:
			pass
		TRANSITION_IN: # 0 to 320
			position.y += SPEED * delta
			position.y = min(320, position.y)
			if position.y >= 320:
				transition = NO_TRANSITION
		TRANSITION_OUT: # -320 to 0
			position.y += SPEED * delta
			position.y = min(0, position.y)
			if position.y >= 0:
				position.y = 0
				transition = NO_TRANSITION
				if to_scene: get_tree().change_scene_to_file(to_scene)
				else: GlobalVariables.load_save()
		TRANSITION_CIRCLE_IN:
			rect.material["shader_parameter/size"] += CIRCLE_SPEED * delta
			if rect.material["shader_parameter/size"] >= rect_size.length() + 1:
				transition = NO_TRANSITION
		TRANSITION_CIRCLE_OUT:
			rect.material["shader_parameter/size"] -= CIRCLE_SPEED * delta
			if rect.material["shader_parameter/size"] <= 0:
				transition = NO_TRANSITION
				if to_scene: get_tree().change_scene_to_file(to_scene)
				else: GlobalVariables.load_save()
		TRANSITION_OPEN_H:
			rect.material["shader_parameter/size"] = (1 - (1 - (1 - (1 - rect.material["shader_parameter/size"] / rect_size.x)**(1./3) + delta)) ** 3) * rect_size.x
			if rect.material["shader_parameter/size"] >= rect_size.x:
				rect.material["shader_parameter/size"] = rect_size.x
				transition = NO_TRANSITION
		TRANSITION_CLOSE_H:
			rect.material["shader_parameter/size"] = (1 - (1 - (1 - (1 - rect.material["shader_parameter/size"] / rect_size.x)**(1./3) - delta)) ** 3) * rect_size.x
			if rect.material["shader_parameter/size"] <= 0:
				rect.material["shader_parameter/size"] = 0
				transition = NO_TRANSITION
				if to_scene: get_tree().change_scene_to_file(to_scene)
				else: GlobalVariables.load_save()
		TRANSITION_OPEN_V:
			rect.material["shader_parameter/size"] = (1 - (1 - (1 - (1 - rect.material["shader_parameter/size"] / rect_size.y)**(1./3) + delta)) ** 3) * rect_size.y
			if rect.material["shader_parameter/size"] >= rect_size.y:
				rect.material["shader_parameter/size"] = rect_size.y
				transition = NO_TRANSITION
		TRANSITION_CLOSE_V:
			rect.material["shader_parameter/size"] = (1 - (1 - (1 - (1 - rect.material["shader_parameter/size"] / rect_size.y)**(1./3) - delta)) ** 3) * rect_size.y
			if rect.material["shader_parameter/size"] <= 0:
				rect.material["shader_parameter/size"] = 0
				transition = NO_TRANSITION
				if to_scene: get_tree().change_scene_to_file(to_scene)
				else: GlobalVariables.load_save()

func change_scene_to_file(scene, t=TRANSITION_CLOSE_H):
	get_tree().paused = true
	if t == TRANSITION_OUT:
		position.y = -320
		rect.material["shader_parameter/size"] = 0
	elif t == TRANSITION_CIRCLE_OUT:
		rect.material["shader_parameter/size"] = rect_size.length() + 1
		position.y = 0
	elif t == TRANSITION_CLOSE_H:
		rect.material["shader_parameter/pos"] = Vector2(rect_size.x, rect_size.y/2)
		rect.material["shader_parameter/size"] = rect_size.x
		position.y = 0
	elif t == TRANSITION_CLOSE_V:
		rect.material["shader_parameter/pos"] = Vector2(rect_size.x/2, rect_size.y)
		rect.material["shader_parameter/size"] = rect_size.y
		position.y = 0
	transition = t
	to_scene = scene

func restart():
	change_scene_to_file(null, TRANSITION_CIRCLE_OUT)

func next_level(path=""):
	start_dir = 1
	if not path:
		#var sub = curr_scene.substr(0, curr_scene.length()-5) # res://level_1
		#var num = int(sub.substr(12)) # 1
		var num = int(get_tree().current_scene.name.substr(5))
		path = "res://level_" + str(num + 1) + ".tscn"
	if ResourceLoader.exists(path):
		change_scene_to_file(path, TRANSITION_CIRCLE_OUT)
	else:
		change_scene_to_file("res://level_1.tscn", TRANSITION_CIRCLE_OUT)

func prev_level(path=""):
	start_dir = -1
	if not path:
		#var sub = curr_scene.substr(0, curr_scene.length()-5) # res://level_1
		#var num = int(sub.substr(12)) # 1
		var num = int(get_tree().current_scene.name.substr(5))
		path = "res://level_" + str(num - 1) + ".tscn"
	if ResourceLoader.exists(path):
		change_scene_to_file(path, TRANSITION_CIRCLE_OUT)
	else:
		change_scene_to_file("res://level_1.tscn", TRANSITION_CIRCLE_OUT)
