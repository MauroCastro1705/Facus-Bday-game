extends Area2D

@onready var shooting_point = %ShootingPoint
@onready var player = get_node("/root/Game/Player")


func _ready():
	pass

func _process(_delta):
	pass

func _physics_process(_delta):
	if player:
		look_at(player.global_position)


#### SHOOT TYPES####
func Normal_Shoot():
	const BULLET = preload("res://BossBullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.global_rotation = shooting_point.global_rotation
	get_parent().add_child(new_bullet)  # Spawn bullet in the main scene


func Burst_Fire():
	const BULLET = preload("res://BossBullet.tscn")
	for i in range(Global.bulletBurstCount):
		await get_tree().create_timer(Global.bulletBurstDelay).timeout
		var new_bullet = BULLET.instantiate()
		new_bullet.global_position = shooting_point.global_position
		new_bullet.global_rotation = shooting_point.global_rotation
		get_parent().add_child(new_bullet)


func _on_boss_atk_timer_timeout() -> void:
	Burst_Fire()
