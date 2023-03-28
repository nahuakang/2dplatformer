extends Node

var player_scene = preload("res://scenes/Player.tscn")
var spawn_position = Vector2.ZERO
var current_player_node = null

func _ready() -> void:
	spawn_position = $Player.global_position
	register_player($Player)
	
func register_player(player: KinematicBody2D):
	current_player_node = player
	current_player_node.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var player_instance = player_scene.instance()
	add_child_below_node(current_player_node, player_instance)
	player_instance.global_position = spawn_position
	register_player(player_instance)

func on_player_died():
	current_player_node.queue_free()
	create_player()
