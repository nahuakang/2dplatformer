extends KinematicBody2D

signal died

enum State { NORMAL, DASH }

var gravity = 1000
var velocity = Vector2.ZERO

var max_horizontal_speed = 150
var horizontal_acceleration = 2500

var max_dash_speed = 500
var min_dash_speed = 200
var is_state_new = true

var jump_speed = 360
var jump_termination_multiplier = 4
var has_double_jump = false

var current_state = State.NORMAL

func _ready() -> void:
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")

func _process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			process_normal(delta)
		State.DASH:
			process_dash(delta)
	
	is_state_new = false

func change_state(new_state) -> void:
	current_state = new_state
	is_state_new = true

func process_normal(delta: float) -> void:
	var move_vector = get_movement_vector()
	
	velocity.x += move_vector.x * horizontal_acceleration * delta
	if (move_vector.x == 0 ):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
	if (move_vector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || has_double_jump)):
		velocity.y = move_vector.y * jump_speed
		
		if (!is_on_floor() && $CoyoteTimer.is_stopped()):
			has_double_jump = false
		
		$CoyoteTimer.stop()
	
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jump_termination_multiplier * delta
	else:
		velocity.y += gravity * delta
		
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (was_on_floor and !is_on_floor()):
		$CoyoteTimer.start()
	
	if (is_on_floor()):
		has_double_jump = true
	
	if (Input.is_action_just_pressed("dash")):
		call_deferred("change_state", State.DASH)
	
	update_animation()

func process_dash(delta: float) -> void:
	if (is_state_new):
		$AnimatedSprite.play("jump")
		var move_vector = get_movement_vector()
		var velocity_mod = 1
		
		if (move_vector.x != 0):
			velocity_mod = sign(move_vector.x)
		else:
			velocity_mod = 1 if $AnimatedSprite.flip_h else -1
		velocity = Vector2(max_dash_speed * velocity_mod, 0)

	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))
	
	if (abs(velocity.x) < min_dash_speed):
		call_deferred("change_state", State.NORMAL)

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

func on_hazard_area_entered(_area2d: Area2D) -> void:
	emit_signal("died")
