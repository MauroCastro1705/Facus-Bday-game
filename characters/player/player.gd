extends CharacterBody2D

var is_dead: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var ui_bottom:Node
@onready var barra_vida:HealthBar = ui_bottom.barra_vida
var max_health: float
var current_health: float

var original_scale: float = 1.0
var shoot_scale: float = 1.3
var scale_timer: float = 0.0

@onready var DAMAGE_RATE = Global.mobDmgRate
@onready var overlapping_mobs = $hurtBox.get_overlapping_bodies()
@onready var movSpeed = Global.playerMovSpeed
@onready var crosshair: AnimatedSprite2D = $crosshair

@export var gun:Node

# Sistema de munición
@export var max_ammo: int = 12  ## Balas por cartucho
var current_ammo: int = 12
var is_reloading: bool = false
@export var reload_time: float = 2.0  ## Tiempo de recarga en segundos
@onready var reload_timer: Timer = $reload_timer

# Sistema de fire rate
@export var fire_rate: float = 0.2  # Tiempo entre disparos en segundos
var can_shoot: bool = true
@onready var fire_rate_timer: Timer = $fire_rate_timer

# Variables para el efecto de disparo
var is_shooting: bool = false
var shoot_flash_timer: float = 0.0
const FLASH_DURATION: float = 0.15

# Variables para el dash
var is_dashing: bool = false
var dash_speed: float = 800.0
var dash_direction: Vector2 = Vector2.ZERO

# Sistema de dashes
@export var dash_cooldown: float = 2.0
@export var dash_duration: float = 0.3

# Timers individuales para cada dash
@onready var dash_1_timer: Timer = $dash_timer
@onready var dash_2_timer: Timer = $dash_timer_2

# Estado de los dashes (true = disponible, false = en cooldown)
var dash_1_available: bool = true
var dash_2_available: bool = true

func _ready() -> void:
	max_health = Global.playerHealth
	current_health = max_health
	
	# Configurar barra de vida
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health
	
	# Configurar munición
	current_ammo = max_ammo
	if ui_bottom and ui_bottom.has_method("set_ammo"):
		ui_bottom.set_ammo(current_ammo, max_ammo)
	
	# Configurar timer de recarga
	if reload_timer:
		reload_timer.wait_time = reload_time
		reload_timer.one_shot = true
		reload_timer.timeout.connect(_on_reload_timer_timeout)
	
	# Configurar timer de fire rate
	if fire_rate_timer:
		fire_rate_timer.wait_time = fire_rate
		fire_rate_timer.one_shot = true
		fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	
	# Configurar timers de dash
	if dash_1_timer:
		dash_1_timer.wait_time = dash_cooldown
		dash_1_timer.one_shot = true
	
	if dash_2_timer:
		dash_2_timer.wait_time = dash_cooldown
		dash_2_timer.one_shot = true

	
	# Inicializar UI
	if ui_bottom and ui_bottom.has_method("reset_all_dashes"):
		ui_bottom.reset_all_dashes()
	
	# Ocultar cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	crosshair.play("default")
	crosshair.modulate = Color.WHITE

func _physics_process(delta):
	Global.playerPosition = position
	
	# Manejar el dash
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
	else:
		var direction = Input.get_vector("move_left","move_right","move_up","move_down")
		velocity = direction * movSpeed
		move_and_slide()
	
	# Crosshair
	crosshair.global_position = get_global_mouse_position()
	
	# Efecto de disparo
	if is_shooting:
		shoot_flash_timer -= delta
		if shoot_flash_timer <= 0:
			crosshair.modulate = Color.WHITE
			is_shooting = false
	
	# Inputs - Solo disparar si NO está recargando y PUEDE disparar
	if Input.is_action_pressed("shoot") and not is_reloading and can_shoot:
		try_shoot()
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		try_dash()

func try_shoot() -> void:
	# Si está recargando, no hacer nada
	if is_reloading:
		return
	
	# Si no puede disparar (en cooldown), no hacer nada
	if not can_shoot:
		return
	
	# Verificar si hay munición
	if current_ammo > 0:
		# Disparar
		shoot_bullet()
		
		# Reducir munición
		current_ammo -= 1
		
		# Efecto visual de disparo
		trigger_shoot_effect()
		
		# Actualizar UI
		if ui_bottom and ui_bottom.has_method("set_ammo"):
			ui_bottom.set_ammo(current_ammo, max_ammo)
		
		print("¡Disparo! Balas restantes: ", current_ammo)
		
		# Activar cooldown del disparo
		can_shoot = false
		if fire_rate_timer:
			fire_rate_timer.start()
		
		# Si nos quedamos sin munición, recargar automáticamente
		if current_ammo == 0:
			start_reload()
	else:
		# Sin munición, recargar automáticamente
		start_reload()

func shoot_bullet() -> void:
	# Aquí va tu código para instanciar la bala
	if gun and gun.has_method("shoot"):
		gun.shoot()

func _on_fire_rate_timer_timeout() -> void:
	# Permitir disparar nuevamente
	can_shoot = true

func start_reload() -> void:
	# No recargar si ya está recargando o si ya está lleno
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	
	# Cambiar crosshair a animación de recarga
	crosshair.play("reloading")
	print("Recargando...")
	
	# Iniciar timer de recarga
	if reload_timer:
		reload_timer.start()

func _on_reload_timer_timeout() -> void:
	# Recargar completamente
	current_ammo = max_ammo
	
	# Actualizar UI
	if ui_bottom and ui_bottom.has_method("set_ammo"):
		ui_bottom.set_ammo(current_ammo, max_ammo)
	
	# Volver al crosshair normal
	crosshair.play("default")
	is_reloading = false
	
	print("Recarga completada! Munición: ", current_ammo)

func trigger_shoot_effect():
	crosshair.modulate = Color.ORANGE
	is_shooting = true
	shoot_flash_timer = FLASH_DURATION

func try_dash() -> void:
	# Intentar usar dash_1 primero
	if dash_1_available:
		start_dash(1)
	# Si dash_1 no está disponible, usar dash_2
	elif dash_2_available:
		start_dash(2)
	else:
		print("No hay dashes disponibles")

func start_dash(dash_number: int) -> void:
	is_dashing = true
	
	# Marcar el dash como no disponible
	match dash_number:
		1:
			dash_1_available = false
			if ui_bottom and ui_bottom.has_method("use_dash_1"):
				ui_bottom.use_dash_1()
			if dash_1_timer:
				dash_1_timer.start()
			print("Usando dash 1")
		2:
			dash_2_available = false
			if ui_bottom and ui_bottom.has_method("use_dash_2"):
				ui_bottom.use_dash_2()
			if dash_2_timer:
				dash_2_timer.start()
			print("Usando dash 2")
	
	# Calcular dirección
	var mouse_position = get_global_mouse_position()
	dash_direction = (mouse_position - global_position).normalized()
	if dash_direction.length() < 0.1:
		dash_direction = Vector2.RIGHT
	
	# Iniciar timer para duración
	await get_tree().create_timer(dash_duration).timeout
	end_dash()

func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO
	print("Dash terminado")

# Cuando el dash 1 se recupera del cooldown
func _on_dash_1_timer_timeout() -> void:
	dash_1_available = true
	if ui_bottom and ui_bottom.has_method("recover_dash_1"):
		ui_bottom.recover_dash_1()
	print("Dash 1 recuperado!")

func take_damage(damage: float):
	if is_dead:
		return
	if is_dashing:
		return
	
	current_health = max(current_health - damage, 0)
	if barra_vida:
		barra_vida.take_damage(damage)

func _on_health_depleted():
	die()

func die():
	if is_dead:
		return
	is_dead = true
	print("Guerrero ha muerto!")
	queue_free()

func _process(_delta):
	if is_shooting:
		var time_remaining = shoot_flash_timer / FLASH_DURATION
		var color = Color.ORANGE.lerp(Color.WHITE, 1.0 - time_remaining)
		crosshair.modulate = color
	
	# Si está recargando, mantener la animación de recarga
	if is_reloading and crosshair.animation != "reloading":
		crosshair.play("reloading")


func _on_dash_timer_2_timeout() -> void:
	dash_2_available = true
	if ui_bottom and ui_bottom.has_method("recover_dash_2"):
		ui_bottom.recover_dash_2()
	print("Dash 2 recuperado!")
