extends Control

@onready var barra_vida: HealthBar = $health_panel/BarraVida
@onready var dash_1: TextureRect = %dash_1
@onready var dash_2: TextureRect = %dash_2
@onready var dash_sprite_timer: AnimatedSprite2D = %dash_sprite_timer
@onready var dash_sprite_timer_2: AnimatedSprite2D = %dash_sprite_timer2
@onready var player_name: Label = %player_name
@onready var weapon_name_label: Label = $gun_panel/weapon_name
@onready var ammo_label: Label = %ammo

@export var weapon_name:String ##nombre para el arma


# Estados de los dashes: true = disponible, false = en cooldown
var dash_1_available: bool = true
var dash_2_available: bool = true

func _ready() -> void:
	weapon_name_label.text = weapon_name
	dash_sprite_timer.hide()
	dash_sprite_timer_2.hide()
	update_all_dashes()

# Actualiza todos los dashs según su estado
func update_all_dashes() -> void:
	update_dash_1()
	update_dash_2()

# Actualiza el dash 1
func update_dash_1() -> void:
	if dash_1_available:
		# Dash disponible - mostrar icono normal
		dash_1.show()
		dash_sprite_timer.hide()
	else:
		# Dash en cooldown - mostrar timer
		dash_1.hide()
		dash_sprite_timer.show()
		dash_sprite_timer.play("default")

# Actualiza el dash 2
func update_dash_2() -> void:
	if dash_2_available:
		# Dash disponible - mostrar icono normal
		dash_2.show()
		dash_sprite_timer_2.hide()
	else:
		# Dash en cooldown - mostrar timer
		dash_2.hide()
		dash_sprite_timer_2.show()
		dash_sprite_timer_2.play("default")

# Función para usar el dash 1 (llamada desde el player)
func use_dash_1() -> void:
	dash_1_available = false
	update_dash_1()

# Función para usar el dash 2 (llamada desde el player)
func use_dash_2() -> void:
	dash_2_available = false
	update_dash_2()

# Función para recuperar el dash 1 (cuando termina el cooldown)
func recover_dash_1() -> void:
	dash_1_available = true
	update_dash_1()

# Función para recuperar el dash 2 (cuando termina el cooldown)
func recover_dash_2() -> void:
	dash_2_available = true
	update_dash_2()

# Resetear todos los dashs
func reset_all_dashes() -> void:
	dash_1_available = true
	dash_2_available = true
	update_all_dashes()

# Obtener cuántos dashs están disponibles
func get_available_dashes() -> int:
	var count = 0
	if dash_1_available:
		count += 1
	if dash_2_available:
		count += 1
	return count
	
func set_ammo(ammo:int , max_ammo:int):
	ammo_label.text = str(ammo , "/" , max_ammo)
