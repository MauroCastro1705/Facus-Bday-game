extends Control


func _on_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _ready():
	update_high_score_display()

func update_high_score_display():
	var high_scores = Global.load_high_scores()
	var text = "🏆 HIGH SCORES 🏆\n"	
	for i in range(high_scores.size()):
		var entry = high_scores[i]
		text += str(i + 1) + ". " + entry["name"] + " - " + str(entry["score"]) + " Pts (Nivel " + str(entry["level"]) + ")\n"    
		%TOP10.text = text
	print(text)
	
