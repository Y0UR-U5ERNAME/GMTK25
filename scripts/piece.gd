extends Area2D
class_name Piece

var on_conveyor := true
var is_held := false
@export var piece_type : int = 0
@onready var faulty := false # faulty pieces do not connect to other pieces
@onready var coll := $CollisionShape2D
@onready var outline := $Outline

enum { # types of pieces
	OUTER_WHEEL,
	INNER_WHEEL,
	WHEEL
}

static func get_parts(type : int) -> Array[int]:
	match type:
		WHEEL: return [OUTER_WHEEL, INNER_WHEEL]
		_: return [type]

func _ready():
	pass
	#position = Vector2(round(position.x), round(position.y))

func _process(delta: float) -> void:
	outline.visible = self == Cursor.piece_touching
	is_held = outline.visible and Input.is_action_pressed("left_click")
	if is_held and Input.is_action_just_pressed("left_click"):
		reparent(Cursor)
	if not is_held and Input.is_action_just_released("left_click"):
		reparent(get_tree().current_scene.get_node("Pieces"))
	
	if on_conveyor and not is_held and get_tree().current_scene.is_moving:
		position.x += 100 * delta
		
	if position.x > 300 and not is_held:
		queue_free()
