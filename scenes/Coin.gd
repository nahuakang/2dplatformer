extends Node2D

func _ready() -> void:
	$Area2D.connect("area_entered", self, "on_area_entered")

func on_area_entered(area2d: Area2D):
	$AnimationPlayer.play("pickup")
	call_deferred("disable_pickup")
	

func disable_pickup() -> void:
	$Area2D/CollisionShape2D.disabled = true
