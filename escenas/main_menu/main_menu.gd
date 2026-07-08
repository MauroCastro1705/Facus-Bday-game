extends Control
@export var main_scene:PackedScene
@export var credits_scene:PackedScene

func _on_start_button_pressed():
	Global.playerNAME = %name_input.text
	print("jugador = ", Global.playerNAME)
	get_tree().change_scene_to_packed(main_scene)
