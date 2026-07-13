extends Control

@export var fade_duration: float = 0.5


func _on_start_button_pressed():
	Global.playerNAME = %name_input.text
	print("jugador = ", Global.playerNAME)
	get_tree().change_scene_to_file("res://escenas/Main/main_scene.tscn")



func _on_creditos_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	await tween.finished
	
	# Cambiar a la escena del main menu
	get_tree().change_scene_to_file("res://escenas/creditos/creditos.tscn")
