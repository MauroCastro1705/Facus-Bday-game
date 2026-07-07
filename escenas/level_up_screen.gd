extends Control

var leveltext = str(Global.playerLEVEL)

func _ready():
	%Nivel_label.text = "Subiste al nivel : " + leveltext
	%Label2.text = "Elegi una mejora para continuar"	


func _on_mas_vidabutton_pressed() -> void:
	Global.playerHealth = min(Global.playerHealth + Global.HealthCoinValue, Global.playerMaxHealth)
	Global.isLevelUpCompleted = true
	print(" lvl up mas vida")
	queue_free()
	get_tree().paused = false

func _on_mas_dmgbutton_3_pressed() -> void:
	Global.playerAtkDmg += 0.5
	Global.isLevelUpCompleted = true
	print(" lvl up mas daño")
	queue_free()
	get_tree().paused = false

func _on_mas_atk_spdbutton_2_pressed() -> void:
	Global.playerAtkSpeed -= Global.AtkSpeedCoinValue
	Global.isLevelUpCompleted = true
	print(" lvl up mas atk speed")
	queue_free()
	get_tree().paused = false
