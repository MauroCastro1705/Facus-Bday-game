extends CharacterBody2D
signal health_depleted
var health = Global.playerHealth

func _physics_process(delta):
	Global.playerPosition = position
	$LevelBar.value = Global.playerExp
	$LevelBar.max_value = Global.expToLvlUp
	$ProgressBar.max_value = Global.playerMaxHealth
	$valorVida.text = str(round(Global.playerHealth)) + " / " + str(round(Global.playerMaxHealth))
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	var movSpeed = Global.playerMovSpeed
	velocity = direction * movSpeed
	move_and_slide()
	
	if velocity.length()> 0.0:
		$HappyBoo.play_walk_animation()
	else:
		$HappyBoo.play_idle_animation()
		
	var DAMAGE_RATE = Global.mobDmgRate
	var overlapping_mobs = $hurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		Global.playerHealth -= DAMAGE_RATE * overlapping_mobs.size() * delta
		$ProgressBar.value = Global.playerHealth
		
		if Global.playerHealth <= 0.0:
			health_depleted.emit()
			print("Player dead")
			Global.save_high_score(Global.playerNAME, Global.playerScore, Global.playerLEVEL)


func take_damage():
	var dmgDone = Global.bigBossAtkDmg
	health -= dmgDone
	Global.playerHealth = health  # Update the global player health
	$ProgressBar.value = Global.playerHealth  # Update the progress bar value
	print("damage take_damage")

	if Global.playerHealth <= 0.0:
		health_depleted.emit()
		print("Player dead")
		Global.save_high_score(Global.playerNAME, Global.playerScore, Global.playerLEVEL)
