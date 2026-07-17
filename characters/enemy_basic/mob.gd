extends CharacterBody2D

signal died
@export var bullet: PackedScene
@export var bullet_speed:int = 350
@export var shoot_timer: Timer
@export var fire_rate: float = 1.5
@export var detection_range: float = 600.0
@export var enemy_speed: float = 100.0
@export var rotation_speed: float = 5.0

@onready var barra_vida: HealthBar = $BarraVida
@export var coin:PackedScene
@export var coin_amount:int
var max_health: float = 80.0
var current_health: float
var is_dead: bool = false

var player: Node2D = null
var can_shoot: bool = true
var is_player_in_range: bool = false

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var velocity_vector: Vector2 = Vector2.ZERO

@onready var weapon: Sprite2D = $gun
@onready var shooting_point: Marker2D = $gun/shooting_point

# ✅ Variable para guardar la posición de muerte
var death_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_health = max_health
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health
	
	find_player()
	
	if shoot_timer == null:
		shoot_timer = Timer.new()
		shoot_timer.wait_time = fire_rate
		shoot_timer.one_shot = false
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		add_child(shoot_timer)
	else:
		shoot_timer.wait_time = fire_rate
		shoot_timer.one_shot = false
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	if player == null:
		find_player()
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	is_player_in_range = distance_to_player <= detection_range
	
	velocity_vector = Vector2.ZERO
	
	if is_player_in_range:
		aim_weapon_at_player(delta)
		var direction = (player.global_position - global_position).normalized()
		velocity_vector = direction * enemy_speed
	else:
		handle_out_of_range(delta)
	
	velocity = velocity_vector
	move_and_slide()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func aim_weapon_at_player(delta: float) -> void:
	if player == null or weapon == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	var target_angle = direction.angle()
	weapon.rotation = lerp_angle(weapon.rotation, target_angle, rotation_speed * delta)
	var facing_left = abs(wrapf(weapon.rotation, -PI, PI)) > PI / 2.0
	weapon.scale.y = -1.0 if facing_left else 1.0

func handle_out_of_range(_delta: float) -> void:
	if not is_moving:
		target_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		is_moving = true
	
	if is_moving:
		var direction = (target_position - global_position).normalized()
		velocity_vector = direction * enemy_speed * 0.5
		
		if global_position.distance_to(target_position) < 10:
			is_moving = false
			velocity_vector = Vector2.ZERO

func _on_shoot_timer_timeout() -> void:
	if not is_player_in_range or player == null:
		return
	shoot()

func shoot() -> void:
	if bullet == null:
		return
	
	var bullet_instance = bullet.instantiate()
	bullet_instance.SPEED = bullet_speed
	
	if shooting_point != null:
		bullet_instance.global_position = shooting_point.global_position
	else:
		bullet_instance.global_position = global_position
	
	var direction = (player.global_position - global_position).normalized()
	bullet_instance.rotation = direction.angle()
	get_parent().add_child(bullet_instance)

func set_fire_rate(rate: float) -> void:
	fire_rate = rate
	if shoot_timer != null:
		shoot_timer.wait_time = rate

func set_detection_range(range_value: float) -> void:
	detection_range = range_value

func take_damage(damage: int) -> void:
	if is_dead:
		return
	
	print("Enemigo recibió daño: ", damage)
	current_health = max(current_health - damage, 0)
	DamageNumbers.display_numbers(damage, global_position)
	if barra_vida:
		barra_vida.take_damage(damage)

func _on_health_depleted():
	if is_dead:
		return
	
	is_dead = true
	
	# ✅ GUARDAR POSICIÓN Y REFERENCIA AL MUNDO
	death_position = global_position
	var world = get_tree().current_scene
	
	# Emitir señal
	died.emit()
	
	# ✅ Call deferred con la posición y referencia al mundo
	call_deferred("spawn_coins_safe", world)
	
	queue_free()

func spawn_coins_safe(world: Node) -> void:
	"""Spawnear monedas de forma segura con referencia al mundo"""
	if world == null:
		world = get_tree().current_scene
		if world == null:
			return
	
	for i in coin_amount:
		var coin_instance = coin.instantiate()
		var offset = Vector2(
			randf_range(-25, 25),
			randf_range(-25, 25)
		)
		coin_instance.global_position = death_position + offset
		world.add_child(coin_instance)

func _enter_tree() -> void:
	add_to_group("enemies")
