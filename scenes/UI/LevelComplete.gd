extends CanvasLayer

func _ready():
	$MarginContainer/VBoxContainer/Button.connect("pressed", self, "on_next_button_pressed")

func on_next_button_pressed() -> void:
	$"/root/LevelManager".increment_level()
