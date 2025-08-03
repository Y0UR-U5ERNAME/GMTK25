extends Area2D
class_name Piece

var on_conveyor := true
var is_held := false
@export var piece_type : int = 0
@onready var faulty := false # faulty pieces do not connect to other pieces
@onready var coll := $CollisionShape2D
@onready var outline := $Outline
var is_attached := false:
	set(x):
		if x:
			is_held = false
			on_conveyor = false
			collision_layer = 0
		is_attached = x

enum { # types of pieces
	OUTER_WHEEL,
	INNER_WHEEL,
	WHEEL
}

static func get_parts(type : int) -> Array[int]:
	match type:
		WHEEL: return [OUTER_WHEEL, INNER_WHEEL]
	return [type]

static func combine(piece1 : Piece, piece2 : Piece) -> void:
	if piece1.faulty or piece2.faulty: return
	if piece1.piece_type == INNER_WHEEL and piece2.piece_type == OUTER_WHEEL:
		piece1.reparent(piece2)
		piece1.position = Vector2.ZERO
		piece1.is_attached = true
		piece2.piece_type = WHEEL
	elif piece1.piece_type == OUTER_WHEEL and piece2.piece_type == INNER_WHEEL:
		piece2.reparent(piece1)
		piece2.position = Vector2.ZERO
		piece2.is_attached = true
		piece1.piece_type = WHEEL

func _ready():
	faulty = randf() < GlobalVariables.faulty_rate
	#position = Vector2(round(position.x), round(position.y))

func _process(delta: float) -> void:
	if is_attached:
		outline.visible = get_parent().outline.visible
	else:
		outline.visible = self == Cursor.piece_touching
		is_held = outline.visible and Input.is_action_pressed("left_click")
		if is_held and Input.is_action_just_pressed("left_click"):
			reparent(Cursor)
			Cursor.held_piece = self
		
		if not is_held:
			global_position.y = clamp(global_position.y, 80, 138)
		
		if on_conveyor and not is_held and get_tree().current_scene.is_moving:
			position.x += 100 * (2./GlobalVariables.move_time) * delta
			
		if position.x > 256+9 and not is_held:
			# maybe make sound effect
			payout()

func payout():
	if piece_type == GlobalVariables.target:
		GlobalVariables.stats[0] += 1
		GlobalVariables.stats[1] += GlobalVariables.piece_values[piece_type]
		GlobalVariables.pay += GlobalVariables.piece_values[piece_type]
	else:
		GlobalVariables.stats[2] += 1
		GlobalVariables.stats[3] += GlobalVariables.piece_values[piece_type]
		GlobalVariables.pay -= GlobalVariables.piece_values[piece_type]
		#for i in get_children():
		#	if i.is_class(self.get_class()): i.payout()
	queue_free()

func payout_faulty():
	if faulty:
		GlobalVariables.stats[4] += 1
		GlobalVariables.stats[5] += GlobalVariables.piece_values[piece_type] / 2
		GlobalVariables.pay += GlobalVariables.piece_values[piece_type] / 2
	else:
		GlobalVariables.stats[6] += 1
		GlobalVariables.stats[7] += GlobalVariables.piece_values[piece_type] # not / 2 so that net value is negative
		GlobalVariables.pay -= GlobalVariables.piece_values[piece_type]
		#for i in get_children():
		#	if i.is_class(self.get_class()): i.payout_faulty()
	queue_free()
