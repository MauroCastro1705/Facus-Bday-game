extends Node

var playerNAME = "jugador"
var playerPosition = Vector2(0, 0)
var isLevelUpCompleted = true
####### player vars ######
var playerAtkDmg = 1.0
var playerHealth = 100.0
var playerMaxHealth = 100.0

var playerCritChance : float = 0.25
var playerCritMulti : float = 2.0
var playerHPREGEN = 0.0
var playerMovSpeed : int = 300
var playerAtkSpeed : float = 0.8

### mob vars ###
var mobVelocity = 150
var mobHealth = 3.0
var mobExpValue = 12
var mobDmgRate = 30.0
#big mob vars
var mobBIGVelocity = 190
var mobBIGHealth = 12.0
var mobBIGDmgRate = 70.0
var mobBIGExpValue = 120

#### big boss mob vars ####
var bigBossVelocity = 100
var bigBossHealth = 1500
var bigBossDmgRate = 100.0
var bigBossExpValue = 500
var bigBossMaxHealth = 1500
var bigBossAtkDmg = 10.0


var playerScore = 0
var scoreMulti = 1.0

#player LEVEL vars
var playerLEVEL = 1
var playerExp = 0
var expToLvlUp = 100

#### BULLETS ###
var bulletRange = 1200
var bulletCant = 3
var bulletSpeed = 500
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

#valores que aumentan los coins ######
var HealthCoinValue = 25
var SpeedCoinValue = 40
var AtkSpeedCoinValue = 0.02
#### Coin funcs ######
func HEALTH_COIN():
	playerHealth = min(playerHealth + HealthCoinValue, playerMaxHealth)
	if HealthCoinsOnScreen > 0:
		HealthCoinsOnScreen -= 1
	print("mas vida")

func ATK_SPD_COIN():
	playerAtkSpeed -= AtkSpeedCoinValue
	if AtkSpeedCoinsOnScreen > 0:
		AtkSpeedCoinsOnScreen -= 1
	print("mas atk speed")

func SPEED_COIN():
	playerMovSpeed += SpeedCoinValue
	if SpeedCoinsOnScreen > 0:
		SpeedCoinsOnScreen -= 1
	print("mas velocidad")




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
	LVL_UP_SCREEN()
	isLevelUpCompleted = false
	
func LVL_UP_SCREEN():
	print("mostrar pantalla de nivel")
	#var lvlUpScreen = preload("res://level_up_screen.tscn").instantiate()
	#get_tree().get_root().add_child(lvlUpScreen)
	#lvlUpScreen.visible = true
	#lvlUpScreen.global_position = playerPosition
	
	
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


func MOB_DAMAGE():
	if playerLEVEL > 5:
		mobDmgRate = 30.0 + (playerLEVEL * 2)
		mobBIGDmgRate = 70.0 + (playerLEVEL * 3)
	else:
		mobDmgRate = 30.0
		mobBIGDmgRate = 70.0
		if playerLEVEL > 10:
			mobDmgRate = 30.0 + (playerLEVEL * 3)
			mobBIGDmgRate = 70.0 + (playerLEVEL * 3)
		else:
			mobDmgRate = 30.0
			mobBIGDmgRate = 70.0

#### GAME FUNCS ####
func GAME_TIMER():
	gameTimer += 1
	if gameTimer >= 16:
		gameTimer = 0
