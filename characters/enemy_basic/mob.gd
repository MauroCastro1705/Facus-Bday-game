extends CharacterBody2D

@export var bullet: PackedScene
@export var shoot_timer: Timer
@export var fire_rate: float = 1.5  # Tiempo entre disparos en segundos
@export var detection_range: float = 600.0  # Rango de detección del jugador
@export var enemy_speed: float = 100.0  # Velocidad de movimiento del enemigo
@export var rotation_speed: float = 5.0  # Velocidad de rotación hacia el jugador

@onready var barra_vida: HealthBar = $BarraVida
@export var coin:PackedScene
var max_health: float = 80.0
var current_health: float
var is_dead: bool = false

var player: Node2D = null
var can_shoot: bool = true
var is_player_in_range: bool = false

# Variables para el movimiento
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var velocity_vector: Vector2 = Vector2.ZERO  # Variable para almacenar la velocidad

# Referencias al arma y punto de disparo
@onready var weapon: Sprite2D = $gun
@onready var shooting_point: Marker2D = $gun/shooting_point

func _ready() -> void:
	# Configurar vida
	current_health = max_health
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health
	
	# Buscar al jugador por grupo
	find_player()
	
	# Configurar el timer si no está asignado
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
	
	# Iniciar el timer
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	# Buscar al jugador constantemente si no se ha encontrado
	if player == null:
		find_player()
		return
	
	# Verificar si el jugador está dentro del rango de detección
	var distance_to_player = global_position.distance_to(player.global_position)
	is_player_in_range = distance_to_player <= detection_range
	
	# Reiniciar velocidad
	velocity_vector = Vector2.ZERO
	
	if is_player_in_range:
		# Apuntar el arma hacia el jugador
		aim_weapon_at_player(delta)
		
		# Calcular dirección hacia el jugador
		var direction = (player.global_position - global_position).normalized()
		
		# Establecer velocidad
		velocity_vector = direction * enemy_speed
	else:
		# Si el jugador está fuera de rango, el enemigo patrulla
		handle_out_of_range(delta)
	
	# Aplicar movimiento usando move_and_slide()
	velocity = velocity_vector
	move_and_slide()

func find_player() -> void:
	# Buscar al jugador por grupo
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func aim_weapon_at_player(delta: float) -> void:
	if player == null or weapon == null:
		return
	
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Rotar el arma hacia el jugador
	var target_angle = direction.angle()
	weapon.rotation = lerp_angle(weapon.rotation, target_angle, rotation_speed * delta)

func handle_out_of_range(_delta: float) -> void:
	# Comportamiento básico de patrulla
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
	
	# Crear la bala
	var bullet_instance = bullet.instantiate()
	
	# Posicionar la bala en el shooting point
	if shooting_point != null:
		bullet_instance.global_position = shooting_point.global_position
	else:
		bullet_instance.global_position = global_position
	
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Rotar la bala hacia el jugador
	bullet_instance.rotation = direction.angle()
	
	# Añadir la bala a la escena
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
	call_deferred("add_coin") 
	print("Enemigo ha muerto!")
	queue_free()

func add_coin() -> void:
	var coin_instance = coin.instantiate()
	coin_instance.global_position = self.global_position
	get_parent().add_child(coin_instance)
	

func _enter_tree() -> void:
	# Añadir el enemigo al grupo "enemies" para referencia
	add_to_group("enemies")
