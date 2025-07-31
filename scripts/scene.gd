extends Node2D
class_name Scene
@export var transition_type = 5

func _ready():
	TransitionManager.get_node('Node2D').start(transition_type)
