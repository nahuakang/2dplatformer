extends KinematicBody2D

var gravity = 1000
var velocity = Vector2.ZERO
var max_horizontal_speed = 150
var horizontal_acceleration = 2500
var jump_speed = 360
var jump_termination_multiplier = 4

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	var move_vector = get_movement_vector()
	
	velocity.x += move_vector.x * horizontal_acceleration * delta
	if (move_vector.x == 0 ):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
	if (move_vector.y < 0 && is_on_floor()):
		velocity.y = move_vector.y * jump_speed
	
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jump_termination_multiplier * delta
	else:
		velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	update_animation()

func get_movement_vector() -> Vector2:
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	
	return move_vector

func update_animation():
	var move_vector = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (move_vector.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (move_vector.x != 0):
		$AnimatedSprite.flip_h = true if move_vector.x > 0 else false
