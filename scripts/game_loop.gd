extends Scene

var is_moving := false
var time : float = 0 # time elapsed since start of day in seconds
# one game hour = 30 irl seconds, 9am - 5pm = 4 minutes of gametime
var is_paused := false

@onready var pieces := $Pieces
@onready var conveyor := $Conveyor

func _ready():
	super()
	time = 0

func _process(delta: float) -> void:
	if not is_paused:
		time += delta
		var modtime := fposmod(time, 12) # 2 seconds move, 10 seconds to work
		if modtime < 2:
			if not is_moving:
				spawn_pieces(Piece.WHEEL)
				is_moving = true
			conveyor.region_rect.position.x = fposmod(conveyor.region_rect.position.x - 100 * delta, 16)
		else:
			if is_moving:
				is_moving = false

func spawn_pieces(type : int, pos : Vector2 = Vector2(0, 100)) -> void:
	var parts := Piece.get_parts(type)
	parts.shuffle()
	for p in parts:
		spawn_piece(p, pos + Vector2.UP.rotated(randf() * 2*PI) * Vector2(1, .5) * randf()*30)

func spawn_piece(type : int, pos : Vector2) -> void:
	var piece = GlobalVariables.pieces[type].instantiate()
	piece.position = pos
	#piece.piece_type = type
	pieces.add_child.call_deferred(piece)
