extends CharacterBody2D
signal health_depleted
@onready var health = Global.playerHealth
@onready var DAMAGE_RATE = Global.mobDmgRate
@onready var overlapping_mobs = $hurtBox.get_overlapping_bodies()
@onready var movSpeed = Global.playerMovSpeed

@export var gun:Node

func _ready() -> void:
	$LevelBar.value = Global.playerExp
	$LevelBar.max_value = Global.expToLvlUp
	$ProgressBar.max_value = Global.playerMaxHealth

func _physics_process(delta):
	Global.playerPosition = position
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	velocity = direction * movSpeed
	move_and_slide()
	calc_mob_dmg(delta)

func calc_mob_dmg(delta):
	if overlapping_mobs.size() > 0:
		Global.playerHealth -= DAMAGE_RATE * overlapping_mobs.size() * delta
		$ProgressBar.value = Global.playerHealth
		check_player_dead()

func take_damage():
	var dmgDone = Global.bigBossAtkDmg
	health -= dmgDone
	Global.playerHealth = health  # Update the global player health
	$ProgressBar.value = Global.playerHealth  # Update the progress bar value
	print("damage take_damage")
	check_player_dead()

func check_player_dead():
	if Global.playerHealth <= 0.0:
		health_depleted.emit()
		print("Player dead")
		Global.save_high_score(Global.playerNAME, Global.playerScore, Global.playerLEVEL)
