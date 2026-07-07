extends Area2D

@onready var shooting_point = %ShootingPoint
@onready var crosshair = %Crosshair  # Reference to the crosshair sprite
var can_shoot = true  # Prevents continuous shooting

func _ready():
	# Make the crosshair always visible since mouse aiming is default
	crosshair.visible = true  

func _process(_delta):
	if Input.is_action_pressed("shoot") and can_shoot:
		Normal_Shoot()
		can_shoot = false
		start_shooting_cooldown()

func start_shooting_cooldown():
	await get_tree().create_timer(Global.playerAtkSpeed).timeout
	can_shoot = true  # Allow shooting again

func _physics_process(_delta):
	if Global.auto_target_enemy:
		var enemies_in_range = get_overlapping_bodies()
		if enemies_in_range.size() > 0:
			look_at(enemies_in_range[0].global_position)  # Aim at the closest enemy
	else:
		look_at(get_global_mouse_position())  # Default: Aim at the mouse
		crosshair.global_position = get_global_mouse_position()  # Move crosshair to cursor

#### SHOOT TYPES####
func Normal_Shoot():
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	get_parent().add_child(new_bullet)  # Spawn bullet in the main scene

##### REWORK THIS ####
#func Spread_Shoot():
#	const BULLET = preload("res://bullet.tscn")
#	var num_bullets = Global.bulletCant
#	var spread_angle = Global.bulletSpeed
#
#	for i in range(num_bullets):
#		var new_bullet = BULLET.instantiate()
#		new_bullet.global_position = shooting_point.global_position
#		
#		# Spread the bullets by adjusting the rotation
#		var angle_offset = deg_to_rad((i - float(num_bullets) / 2.0) * spread_angle)
#		new_bullet.global_rotation = shooting_point.global_rotation + angle_offset
#		
#		get_parent().add_child(new_bullet)

func Burst_Fire():
	const BULLET = preload("res://bullet.tscn")
	for i in range(Global.bulletBurstCount):
		await get_tree().create_timer(Global.bulletBurstDelay).timeout
		var new_bullet = BULLET.instantiate()
		new_bullet.global_position = shooting_point.global_position
		new_bullet.global_rotation = shooting_point.global_rotation
		get_parent().add_child(new_bullet)

# Call this function when the skill/effect activates (Switch to Auto-Aim)
func activate_auto_aim():
	Global.auto_target_enemy = true
	crosshair.visible = true  # Hide crosshair (not needed in auto-aim mode)

# Call this function when the skill/effect ends (Return to Mouse Aim)
func deactivate_auto_aim():
	Global.auto_target_enemy = false
	crosshair.visible = true  # Show crosshair again
