extends Position2D

enum Direction { RIGHT, LEFT }

export(Direction) var start_direction
export(PackedScene) var enemy_scene

var current_enemy_node = null
var spawn_on_next_tick = false

func _ready():
	$SpawnTimer.connect("timeout", self, "on_spawn_timer_timeout")
	call_deferred("spawn_enemy")

func spawn_enemy() -> void:
	current_enemy_node = enemy_scene.instance()
	current_enemy_node.start_direction = Vector2.RIGHT if start_direction == Direction.RIGHT else Vector2.LEFT
	# get_parent() will return Enemies node in a Level scene and add Enemy to it
	# This assumes that EnemySpawner is only child to Enemies 
	get_parent().add_child(current_enemy_node)
	current_enemy_node.global_position = global_position

func check_enemy_spawn() -> void:
	if (!is_instance_valid(current_enemy_node)):
		if (spawn_on_next_tick):
			spawn_enemy()
			spawn_on_next_tick = false
		else:
			spawn_on_next_tick = true

func on_spawn_timer_timeout() -> void:
	check_enemy_spawn()
