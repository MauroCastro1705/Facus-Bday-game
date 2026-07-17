extends Node

@warning_ignore("unused_signal")
signal stats_updated


var playerNAME = "jugador"
var playerPosition = Vector2(0, 0)
var isLevelUpCompleted = true
var player_coins:int = 100
####### player vars ######
var playerAtkDmg:float = 10.0
var playerAmmo:int = 12

var playerHealth = 100.0
var playerMaxHealth = 100.0


var playerMovSpeed : int = 300
var playerAtkSpeed : float = 0.8


var playerScore = 0
var scoreMulti = 1.0

#player LEVEL vars
var playerLEVEL = 1
var playerExp = 0
var expToLvlUp = 100

#### BULLETS ###
var bulletRange = 1200
var bulletCant = 3
var bulletSpeed = 800
var bulletSpread = 15
var bulletBurstCount = 3
var bulletBurstDelay = 0.4		


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




func ADD_EXP(amount):
	playerExp += amount
	print("experiencia = " , playerExp)
	if playerExp >= expToLvlUp:
		LVL_UP()
		

func LVL_UP():
	playerExp -= expToLvlUp
	playerLEVEL += 1
	expToLvlUp = round(expToLvlUp * 1.2)  # Incremento del 20% en cada nivel
	playerMaxHealth += 10 + (playerLEVEL * 2)
	playerHealth = playerMaxHealth
	print("subio a nivel = " , playerLEVEL)
	print("VIDA SUBIO a" , playerMaxHealth)
	get_tree().paused = true
	isLevelUpCompleted = false
	

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
