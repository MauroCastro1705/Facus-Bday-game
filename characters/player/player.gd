extends CharacterBody2D

var is_dead: bool = false

@onready var barra_vida: HealthBar = $BarraVida
var max_health: float
var current_health: float

@onready var DAMAGE_RATE = Global.mobDmgRate
@onready var overlapping_mobs = $hurtBox.get_overlapping_bodies()
@onready var movSpeed = Global.playerMovSpeed
@onready var crosshair: AnimatedSprite2D = $crosshair

@export var gun:Node

# Variables para el efecto de disparo
var is_shooting: bool = false
var shoot_flash_timer: float = 0.0
const FLASH_DURATION: float = 0.15  # Duración del flash en segundos

func _ready() -> void:
	max_health = Global.playerHealth
	current_health = max_health
	
	# Configurar barra de vida
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health
	
	# Ocultar el cursor del sistema y usar nuestro crosshair
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Configurar el crosshair inicialmente
	crosshair.play("default")
	crosshair.modulate = Color.WHITE  # Color normal

func _physics_process(_delta):
	Global.playerPosition = position
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * movSpeed
	move_and_slide()
	
	# Actualizar la posición del crosshair al mouse
	crosshair.global_position = get_global_mouse_position()
	
	# Manejar el efecto de flash del disparo
	if is_shooting:
		shoot_flash_timer -= _delta
		if shoot_flash_timer <= 0:
			# Volver al color normal
			crosshair.modulate = Color.WHITE
			is_shooting = false
	
	# Detectar el input de disparo
	if Input.is_action_just_pressed("shoot"):
		trigger_shoot_effect()

func trigger_shoot_effect():
	# Cambiar el color del crosshair a naranja/amarillo
	crosshair.modulate = Color.ORANGE  # O puedes usar Color.YELLOW
	
	# También puedes combinar ambos colores para un efecto más vibrante
	# crosshair.modulate = Color(1.0, 0.8, 0.2)  # Color amarillo-naranja
	
	# Iniciar el temporizador para el flash
	is_shooting = true
	shoot_flash_timer = FLASH_DURATION
	
	# Aquí puedes añadir más efectos de disparo si lo deseas
	print("¡Disparo!")

func take_damage(damage: float):
	if is_dead:
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

# Opcional: Si quieres un efecto más complejo con interpolación de colores
func _process(_delta):
	# Este método es alternativo al flash simple
	if is_shooting:
		# Puedes hacer un efecto de parpadeo más complejo aquí
		var time_remaining = shoot_flash_timer / FLASH_DURATION
		# Interpolar entre naranja y blanco
		var color = Color.ORANGE.lerp(Color.WHITE, 1.0 - time_remaining)
		crosshair.modulate = color
