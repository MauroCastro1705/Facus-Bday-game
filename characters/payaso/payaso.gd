extends CharacterBody2D
@onready var luz: PointLight2D = $PointLight2D

signal died
@export var bullet: PackedScene
@export var bullet_speed:int = 350
@export var shoot_timer: Timer
@export var fire_rate: float = 1.5  # Tiempo entre disparos en segundos
@export var detection_range: float = 600.0  # Rango de detección del jugador
@export var enemy_speed: float = 100.0  # Velocidad de movimiento del enemigo
@export var rotation_speed: float = 5.0  # Velocidad de rotación hacia el jugador

# Configuración de modos de disparo
enum ShootMode {
	SINGLE,        # Disparo único normal
	SHOTGUN,       # Dispersión tipo escopeta
	SPREAD,        # Dispersión en abanico
	DOUBLE,        # Dos disparos paralelos
	TRIPLE,        # Tres disparos en abanico
	RING,          # Anillo de balas
}

@export var shoot_mode: ShootMode = ShootMode.SINGLE
@export var spread_count: int = 5  # Número de balas para disparos dispersos
@export var spread_angle: float = 30.0  # Ángulo total de dispersión en grados
@export var ring_count: int = 8  # Número de balas en un anillo
@export var shot_alternate: bool = false  # Para modo ALTERNATING
var shot_side: int = -1  # -1 izquierda, 1 derecha

@onready var barra_vida: HealthBar = $BarraVida
@export var coin:PackedScene
@export var coin_amount:int ##cantidad de monedas a spawnear
@export var max_health: float = 200.0
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
	var target_angle = direction.angle()
	
	# Rotar el arma hacia el jugador
	weapon.rotation = lerp_angle(weapon.rotation, target_angle, rotation_speed * delta)
	
	# CORRECCIÓN: Flip vertical y horizontal cuando mira a la izquierda
	if direction.x < 0:
		# Cuando mira a la izquierda, el arma debe estar boca abajo
		weapon.flip_v = true
		# Ajustar la posición del arma si es necesario
		weapon.position.x = abs(weapon.position.x) * -1  # Invertir posición X
	else:
		weapon.flip_v = false
		weapon.position.x = abs(weapon.position.x)  # Posición X positiva

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
	
	# Disparar según el modo seleccionado
	match shoot_mode:
		ShootMode.SINGLE:
			shoot_single()
		ShootMode.SHOTGUN:
			shoot_shotgun()
		ShootMode.SPREAD:
			shoot_spread()
		ShootMode.DOUBLE:
			shoot_double()
		ShootMode.TRIPLE:
			shoot_triple()
		ShootMode.RING:
			shoot_ring()


func create_bullet(angle_offset: float = 0.0, offset_distance: float = 0.0) -> void:
	var bullet_instance = bullet.instantiate()
	bullet_instance.SPEED = bullet_speed
	
	# Posicionar la bala en el shooting point con offset
	if shooting_point != null:
		var offset_pos = Vector2(offset_distance, 0).rotated(weapon.rotation + angle_offset)
		bullet_instance.global_position = shooting_point.global_position + offset_pos
	else:
		bullet_instance.global_position = global_position
	
	# Calcular dirección hacia el jugador con el offset de ángulo
	var direction = (player.global_position - global_position).normalized()
	var angle = direction.angle() + deg_to_rad(angle_offset)
	bullet_instance.rotation = angle
	
	# Añadir la bala a la escena
	get_parent().add_child(bullet_instance)

# Modos de disparo
func shoot_single() -> void:
	create_bullet()

func shoot_shotgun() -> void:
	# Dispersión tipo escopeta con variación aleatoria
	for i in range(spread_count):
		var random_offset = randf_range(-spread_angle/2, spread_angle/2)
		create_bullet(random_offset)

func shoot_spread() -> void:
	# Dispersión en abanico uniforme
	for i in range(spread_count):
		var t = float(i) / float(spread_count - 1) if spread_count > 1 else 0.5
		var angle = -spread_angle/2 + t * spread_angle
		create_bullet(angle)

func shoot_double() -> void:
	# Dos disparos paralelos
	create_bullet(-20.0)
	create_bullet(20.0)

func shoot_triple() -> void:
	# Tres disparos en abanico
	create_bullet(-25.0)
	create_bullet(0.0)
	create_bullet(25.0)

func shoot_ring() -> void:
	# Anillo de balas
	for i in range(ring_count):
		var angle = (360.0 / ring_count) * i
		create_bullet(angle)

# Funciones para cambiar modos de disparo desde el inspector
func set_shoot_mode(mode: ShootMode) -> void:
	shoot_mode = mode

func set_spread_count(count: int) -> void:
	spread_count = max(count, 1)

func set_spread_angle(angle: float) -> void:
	spread_angle = max(angle, 0)

func set_ring_count(count: int) -> void:
	ring_count = max(count, 3)

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
	print("Enemigo ha muerto!, señal emitida")
	died.emit()
	queue_free()

func add_coin() -> void:
	for i in coin_amount:
		var coin_instance = coin.instantiate()
		var offset = Vector2(
			randf_range(-50, 50),
			randf_range(-50, 50)
		)
		coin_instance.global_position = global_position + offset
		get_parent().add_child(coin_instance)

func _enter_tree() -> void:
	# Añadir el enemigo al grupo "enemies" para referencia
	add_to_group("enemies")
