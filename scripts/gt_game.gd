extends Node2D

var score := 0:
	set(x):
		score = x
		if x > GlobalVariables.hi_score:
			GlobalVariables.hi_score = x
@onready var fbp := $FBPlayer
@onready var bg: Sprite2D = $BG
@onready var clouds: Sprite2D = $Clouds
@onready var ground_sprite: Sprite2D = $Ground/Sprite2D
@onready var pipes: Node = $Pipes
@onready var label: Label = $Label

var to_next_pipe := 0.0

func _ready():
	start()

func _on_fb_player_die() -> void:
	start()

func start():
	bg.region_rect.position.x = 0
	clouds.region_rect.position.x = 0
	ground_sprite.region_rect.position.x = 0
	score = 0
	fbp.position = Vector2(12, 32)
	fbp.velocity = Vector2.ZERO
	to_next_pipe = 0
	for i in pipes.get_children():
		i.queue_free()

func _process(delta: float) -> void:
	bg.region_rect.position.x += 10 * delta
	clouds.region_rect.position.x += 5 * delta
	ground_sprite.region_rect.position.x += 20 * delta
	
	label.text = "SCORE: %d\nHI: %d" % [score, GlobalVariables.hi_score]
	
	to_next_pipe -= delta
	if to_next_pipe <= 0:
		to_next_pipe += 2
		var p = preload("res://scenes/pipe.tscn").instantiate()
		p.position = Vector2(96, 64/2 + randi_range(-32 + 12, 32 - 12))
		pipes.add_child.call_deferred(p)
