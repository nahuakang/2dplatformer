extends Camera2D

# Scene Exports
export(Color, RGB) var background_color
export(OpenSimplexNoise) var shake_noise

var target_position = Vector2.ZERO

# Camera Shake Variables
var x_noise_sample_vector: Vector2 = Vector2.RIGHT
var y_noise_sample_vector: Vector2 = Vector2.DOWN
var x_noise_sample_position: Vector2 = Vector2.ZERO
var y_noise_sample_position: Vector2 = Vector2.ZERO
var noise_sample_travel_rate: int = 500
var max_shake_offset: int = 10
var current_shake_percentage: float = 0
var shake_decay = 4  # How much percentage per second for decaying

func _ready():
	VisualServer.set_default_clear_color(background_color)

func _process(delta: float) -> void:
	target_position = acquire_target_position()

	global_position = lerp(target_position, global_position, pow(2, -15 * delta))

	# Debug camera shake on jump
#	if (Input.is_action_just_pressed("jump")):
#	apply_shake(1)

	if (current_shake_percentage > 0):
		# Noise sample position on X/Y-axis shifts right/down by a rate of noise_sample_travel_rate per time delta
		x_noise_sample_position += x_noise_sample_vector * noise_sample_travel_rate * delta
		y_noise_sample_position += y_noise_sample_vector * noise_sample_travel_rate * delta

		var x_sample = shake_noise.get_noise_2d(x_noise_sample_position.x, x_noise_sample_position.y)
		var y_sample = shake_noise.get_noise_2d(y_noise_sample_position.x, y_noise_sample_position.y)

		# Vector2(x_sample, y_sample) * max_shake_offset => -4 <-> 4 value for each component
		var calculated_offset = Vector2(x_sample, y_sample) * max_shake_offset * pow(current_shake_percentage, 2)

		# Update camera's offset
		offset = calculated_offset

		# Apply shake decay
		current_shake_percentage = clamp(current_shake_percentage - shake_decay, 0, 1)

func apply_shake(percentage: float) -> void:
	current_shake_percentage = clamp(current_shake_percentage + percentage, 0, 1)

func acquire_target_position() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if (players.size() > 0):
		var player = players[0]
		return player.global_position
	else:
		return Vector2.ZERO
