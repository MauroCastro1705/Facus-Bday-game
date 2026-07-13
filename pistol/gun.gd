extends Node2D

#GUN.gd
@onready var shooting_point = %ShootingPoint
@export var bullet:PackedScene
@onready var pistol: Sprite2D = $pistol
@onready var flash_particle: GPUParticles2D = $GPUParticles2D

func _ready():
	pass



func _physics_process(_delta):
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	
	# Rotar el arma hacia el mouse
	rotation = direction.angle()
	
	# Flip vertical cuando mira a la izquierda
	if direction.x < 0:
		pistol.flip_v = true

	else:
		pistol.flip_v = false

#### SHOOT TYPES####
func shoot():
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	flash_particle.restart()
	flash_particle.emitting = true
	get_parent().add_child(new_bullet)  # Spawn bullet in the main scene

func Burst_Fire():
	for i in range(Global.bulletBurstCount):
		await get_tree().create_timer(Global.bulletBurstDelay).timeout
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = shooting_point.global_position
		new_bullet.global_rotation = shooting_point.global_rotation
		get_parent().add_child(new_bullet)
