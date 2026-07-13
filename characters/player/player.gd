extends CharacterBody2D

var is_dead: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# var barra_vida: HealthBar = $BarraVida
@export var ui_bottom:Node
@onready var barra_vida:HealthBar = ui_bottom.barra_vida
var max_health: float
var current_health: float
#arma
var original_scale: float = 1.0
var shoot_scale: float = 1.3
var scale_timer: float = 0.0

@onready var DAMAGE_RATE = Global.mobDmgRate
@onready var overlapping_mobs = $hurtBox.get_overlapping_bodies()
@onready var movSpeed = Global.playerMovSpeed
@onready var crosshair: AnimatedSprite2D = $crosshair

@export var gun:Node

# Variables para el efecto de disparo
var is_shooting: bool = false
var shoot_flash_timer: float = 0.0
const FLASH_DURATION: float = 0.15  # Duración del flash en segundos

# Variables para el dash
var is_dashing: bool = false
var dash_speed: float = 800.0  # Velocidad del dash
var dash_direction: Vector2 = Vector2.ZERO

# Sistema de dashes con cooldown
@export var max_dash_count: int = 2  # Número máximo de dashes
@export var dash_cooldown: float = 2.0  # Tiempo de cooldown en segundos
@export var dash_duration: float = 0.3  # Duración del dash en segundos

var current_dash_count: int = 2  # Dashes disponibles actualmente
var is_cooldown_active: bool = false  # Si el cooldown está activo

# Timer para el dash (ya creado en la escena)
@onready var dash_timer: Timer = $dash_timer

func _ready() -> void:
	max_health = Global.playerHealth
	current_health = max_health
	
	# Configurar barra de vida
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health
	
	# Configurar el timer de dash
	if dash_timer:
		dash_timer.wait_time = dash_cooldown
		dash_timer.one_shot = true
		# La señal timeout ya está conectada a _on_dash_timer_timeout
	
	# Inicializar dashes
	if ui_bottom and ui_bottom.has_method("update_dash_display"):
		ui_bottom.update_dash_display(max_dash_count, false)
	current_dash_count = max_dash_count
	
	# Ocultar el cursor del sistema y usar nuestro crosshair
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Configurar el crosshair inicialmente
	crosshair.play("default")
	crosshair.modulate = Color.WHITE  # Color normal

func _physics_process(delta):
	Global.playerPosition = position
	
	# Manejar el dash
	if is_dashing:
		# Movimiento del dash
		velocity = dash_direction * dash_speed
		move_and_slide()
	else:
		# Movimiento normal
		var direction = Input.get_vector("move_left","move_right","move_up","move_down")
		velocity = direction * movSpeed
		move_and_slide()
	
	# Actualizar la posición del crosshair al mouse
	crosshair.global_position = get_global_mouse_position()
	
	# Manejar el efecto de flash del disparo
	if is_shooting:
		shoot_flash_timer -= delta
		if shoot_flash_timer <= 0:
			# Volver al color normal
			crosshair.modulate = Color.WHITE
			is_shooting = false
	
	# Detectar el input de disparo
	if Input.is_action_just_pressed("shoot"):
		trigger_shoot_effect()
	
	# Detectar el input de dash
	if Input.is_action_just_pressed("dash") and not is_dashing and current_dash_count > 0 and not is_cooldown_active:
		start_dash()

func start_dash():
	is_dashing = true
	current_dash_count -= 1
	# Actualizar UI - Iniciar cooldown
	if ui_bottom and ui_bottom.has_method("update_dash_display"):
		ui_bottom.update_dash_display(current_dash_count, true)
	# Iniciar cooldown
	is_cooldown_active = true
	if dash_timer:
		dash_timer.start()
	
	# Calcular dirección del dash hacia el mouse
	var mouse_position = get_global_mouse_position()
	dash_direction = (mouse_position - global_position).normalized()
	
	# Si el mouse está muy cerca, dash hacia adelante
	if dash_direction.length() < 0.1:
		dash_direction = Vector2.RIGHT  # Dirección por defecto
	
	# Iniciar timer para la duración del dash
	await get_tree().create_timer(dash_duration).timeout
	end_dash()
	
	print("¡Dash activado! Dashes restantes: ", current_dash_count)

func end_dash():
	is_dashing = false
	velocity = Vector2.ZERO
	print("Dash terminado")

func _on_dash_timer_timeout() -> void:
	is_cooldown_active = false
	if current_dash_count < max_dash_count:
		current_dash_count += 1	
	if ui_bottom and ui_bottom.has_method("update_dash_display"):
		ui_bottom.update_dash_display(current_dash_count, false)
	print("Dash recuperado! Dashes disponibles: ", current_dash_count)

func trigger_shoot_effect():
	crosshair.modulate = Color.ORANGE  # O puedes usar Color.YELLOW
	# Iniciar el temporizador para el flash
	is_shooting = true
	shoot_flash_timer = FLASH_DURATION
	
	# Aquí puedes añadir más efectos de disparo si lo deseas
	print("¡Disparo!")

func take_damage(damage: float):
	if is_dead:
		return
	
	# Si está en dash, no recibe daño (opcional)
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
	update_dash_ui()

##Mostrar visualmente los dashes disponibles
func update_dash_ui() -> void:
	pass
