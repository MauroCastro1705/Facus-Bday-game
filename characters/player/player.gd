extends CharacterBody2D

var is_dead: bool = false

@onready var barra_vida: HealthBar = $BarraVida
var max_health: float
var current_health: float

@onready var DAMAGE_RATE = Global.mobDmgRate
@onready var overlapping_mobs = $hurtBox.get_overlapping_bodies()
@onready var movSpeed = Global.playerMovSpeed

@export var gun:Node

func _ready() -> void:
	max_health = Global.playerHealth
	current_health = max_health
	
	# Configurar barra de vida
	barra_vida.health_depleted.connect(_on_health_depleted)
	barra_vida.max_health = max_health
	barra_vida.current_health = current_health


func _physics_process(_delta):
	Global.playerPosition = position
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * movSpeed
	move_and_slide()



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
