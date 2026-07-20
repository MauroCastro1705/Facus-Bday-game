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



func RESET_STATS():
	player_coins = 167
	bullet_global_size = Vector2(0.5,0.5)
	playerAmmo = 12
	playerAtkDmg = 10.0
	
