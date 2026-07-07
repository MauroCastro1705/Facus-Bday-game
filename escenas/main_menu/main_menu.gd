extends Control


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://survivors-game.tscn")
	Global.playerNAME = %name_input.text
	print("jugador = " , Global.playerNAME)
