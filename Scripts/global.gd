extends Node

@warning_ignore("unused_signal")
signal stats_updated


var playerNAME = "jugador"
var playerPosition = Vector2(0, 0)
var isLevelUpCompleted = true
var player_coins:int = 167
####### player vars ######
var playerAtkDmg:float = 10.0
var playerAmmo:int = 12
var bullet_global_size:Vector2 = Vector2(0.5,0.5)


var playerHealth = 100.0
var playerMaxHealth = 100.0


var playerMovSpeed : int = 200
var playerAtkSpeed : float = 0.8


var playerScore = 0
var scoreMulti = 1.0


#### BULLETS ###
var bulletRange = 1200
var bulletSpeed = 800


### enemigos daño balas
var mob_basico_dmg:float = 11
var mob_torreta_dmg:float = 8
var enemy_room_count:int = 0
var enemy_room_left:int = 0
#### GAME VARS ###
var gameTimer = 0

##### PERKS #####
@export var auto_target_enemy: bool = false
var shootTypeSpread: bool = false
var shootTypeNormal: bool = true

#COINS ######
var HealthCoinsOnScreen = 0
var SpeedCoinsOnScreen = 0 
var AtkSpeedCoinsOnScreen = 0

func RESET_COINS():
	HealthCoinsOnScreen = 0
	SpeedCoinsOnScreen = 0
	AtkSpeedCoinsOnScreen = 0
	

	#SAVE DATA TOP PLAYERS######
const SAVE_FILE = "user://highscores.json"
func save_high_score(player_name, score, level):
	var high_scores = load_high_scores()  # Cargar puntajes anteriores
	high_scores.append({"name": player_name, "score": score, "level": level})    
	# Ordenar por puntaje en orden descendente
	high_scores.sort_custom(func(a, b): return a["score"] > b["score"])    
	if high_scores.size() > 10:    # Mantener solo los 10 mejores
		high_scores = high_scores.slice(0, 10)
	# Guardar el archivo actualizado
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))
	file.close()
	
func load_high_scores():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data is Array:
			return data
	return []  # Si no hay archivo, devuelve una lista vacía
