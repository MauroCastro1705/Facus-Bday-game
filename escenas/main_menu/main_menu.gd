extends Control

@export var fade_duration: float = 0.5
@onready var tutorial: Button = $tutorial
@onready var tutorial_info: ColorRect = $tutorial/tutorial_info

func _ready() -> void:
	tutorial_info.hide()

func _on_start_button_pressed():
	Global.RESET_STATS()
	TransitionManager.change_scene("res://escenas/Main/main_scene.tscn")



func _on_creditos_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	await tween.finished
	
	# Cambiar a la escena del main menu
	TransitionManager.change_scene("res://escenas/creditos/creditos.tscn")


func _on_tutorial_toggled(toggled_on: bool) -> void:
	if toggled_on:
		tutorial.text = "X - cerrar"
		tutorial_info.show()
	else:
		tutorial.text = "Tutorial"
		tutorial_info.hide()
