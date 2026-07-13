extends CharacterBody2D
# Static Turret Enemy

@export var bullet: PackedScene
@export var coin:PackedScene
@export var coin_amount:int ##cantidad de monedas que spawnea al morir
@export var shoot_timer: Timer
@export var fire_rate: float = 1.5  ## Tiempo entre disparos en segundos
@export var detection_range: float = 600.0  ## Rango de detección del jugador

# Tipos de disparo
enum ShootType {
	NORMAL,      ## Un solo disparo directo
	SPREAD,      ## Disparo en abanico (como escopeta)
	LINE_SPREAD  ## Disparos en línea recta vertical/horizontal
}

@export var shoot_type: ShootType = ShootType.NORMAL  ## Tipo de disparo seleccionado
@export var bullet_count: int = 5  ## Número de balas para spread y line_spread
@export var spread_angle: float = 45.0  ## Ángulo total del spread en grados
@export var line_spread_spacing: float = 30.0  ## Espaciado entre balas en línea recta

@onready var barra_vida: HealthBar = $BarraVida
@export var max_health: float = 50 ##vida maxima del enemigo
var current_health: float
var is_dead: bool = false

var player: Node2D = null
var can_shoot: bool = true
var is_player_in_range: bool = false

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
	
	# Solo apuntar si el jugador está en rango
	if is_player_in_range:
		aim_weapon_at_player(delta)

func find_player() -> void:
	# Buscar al jugador por grupo
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func aim_weapon_at_player(_delta: float) -> void:
	if player == null or weapon == null:
		return
	
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Rotar el arma hacia el jugador de forma instantánea (enemigo estático)
	weapon.rotation = direction.angle()

func _on_shoot_timer_timeout() -> void:
	if not is_player_in_range or player == null or is_dead:
		return
	
	shoot()

func shoot() -> void:
	if bullet == null:
		return
	
	# Calcular dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	var base_angle = direction.angle()
	
	match shoot_type:
		ShootType.NORMAL:
			shoot_normal(base_angle)
		
		ShootType.SPREAD:
			shoot_spread(base_angle)
		
		ShootType.LINE_SPREAD:
			shoot_line_spread(base_angle)

func shoot_normal(angle: float) -> void:
	# Un solo disparo directo
	var bullet_instance = bullet.instantiate()
	place_bullet(bullet_instance, angle)
	get_parent().add_child(bullet_instance)

func shoot_spread(base_angle: float) -> void:
	# Disparo en abanico (como escopeta)
	var spread_radians = deg_to_rad(spread_angle)
	var angle_step = 0
	if bullet_count > 1:
		angle_step = spread_radians / (bullet_count - 1)
	var start_angle = base_angle - (spread_radians / 2)
	
	for i in range(bullet_count):
		var bullet_instance = bullet.instantiate()
		var angle = start_angle + (angle_step * i)
		place_bullet(bullet_instance, angle)
		get_parent().add_child(bullet_instance)

func shoot_line_spread(base_angle: float) -> void:
	# Disparos en línea recta perpendicular a la dirección
	# La línea se forma en el eje perpendicular al disparo principal
	
	# Calcular el ángulo perpendicular (90 grados)
	var perp_angle = base_angle + deg_to_rad(90)
	
	# Para un número par de balas, centrar en el punto medio
	var start_offset = -(bullet_count - 1) * line_spread_spacing / 2.0
	
	for i in range(bullet_count):
		var bullet_instance = bullet.instantiate()
		
		# Calcular posición de la bala en línea recta
		var offset = start_offset + i * line_spread_spacing
		var offset_vector = Vector2(cos(perp_angle), sin(perp_angle)) * offset
		
		# Posicionar la bala en el punto de disparo + offset
		if shooting_point != null:
			bullet_instance.global_position = shooting_point.global_position + offset_vector
		else:
			bullet_instance.global_position = global_position + offset_vector
		
		# Todas las balas apuntan en la dirección base
		bullet_instance.rotation = base_angle
		
		get_parent().add_child(bullet_instance)

func place_bullet(bullet_instance: Node2D, angle: float) -> void:
	# Posicionar la bala en el shooting point
	if shooting_point != null:
		bullet_instance.global_position = shooting_point.global_position
	else:
		bullet_instance.global_position = global_position
	
	# Rotar la bala hacia el ángulo especificado
	bullet_instance.rotation = angle

func take_damage(damage: int) -> void:
	if is_dead:
		return
	
	current_health = max(current_health - damage, 0)
	DamageNumbers.display_numbers(damage, global_position)
	if barra_vida:
		barra_vida.take_damage(damage)

func _on_health_depleted():
	if is_dead:
		return
	
	is_dead = true
	print("Enemigo estático ha muerto!")
	call_deferred("add_coin") 
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
