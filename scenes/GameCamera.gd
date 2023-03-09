extends Camera2D

export(Color, RGB) var background_color

var target_position = Vector2.ZERO

func _ready():
	VisualServer.set_default_clear_color(background_color)

func _process(delta: float) -> void:
	var target_position = acquire_target_position()
	
	global_position = lerp(target_position, global_position, pow(2, -15 * delta))
	

func acquire_target_position() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if (players.size() > 0):
		var player = players[0]
		return player.global_position
	else:
		return Vector2.ZERO
