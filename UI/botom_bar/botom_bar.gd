extends Control
@onready var barra_vida: HealthBar = $BarraVida
@onready var dash_1: TextureRect = %dash_1
@onready var dash_2: TextureRect = %dash_2
@onready var dash_sprite_timer: AnimatedSprite2D = %dash_sprite_timer
@onready var dash_sprite_timer_2: AnimatedSprite2D = %dash_sprite_timer2

func _ready() -> void:
	dash_sprite_timer.hide()
	dash_sprite_timer_2.hide()
	update_dash_display(2, false)

func update_dash_display(dashes_available: int, is_cooldown: bool = false) -> void:
	# Actualizar dashs disponibles
	update_dash_availability(dashes_available)
	
	# Actualizar cooldown
	if is_cooldown:
		update_cooldown_indicators(dashes_available)
	else:
		hide_all_cooldown_indicators()

func update_dash_availability(dashes_available: int) -> void:
	# Mostrar los dashs según cuántos están disponibles
	match dashes_available:
		0:
			dash_1.hide()
			dash_2.hide()
		1:
			dash_1.show()
			dash_2.hide()
		2:
			dash_1.show()
			dash_2.show()
		_:
			# Por si hay más de 2 dashs
			dash_1.show()
			dash_2.show()

func update_cooldown_indicators(dashes_available: int) -> void:
	# Mostrar indicadores de cooldown SOLO para los dashs que están en cooldown
	match dashes_available:
		0:
			# Ambos dashs están en cooldown
			dash_sprite_timer.show()
			dash_sprite_timer_2.show()
			dash_sprite_timer.play("default")
			dash_sprite_timer_2.play("default")
		1:
			# Un dash está en cooldown (el que se usó) y el otro está disponible
			# Mostrar timer en la posición del dash que está en cooldown
			dash_sprite_timer.show()
			dash_sprite_timer.play("default")
			dash_sprite_timer_2.hide()
		2:
			# No debería pasar porque si hay 2 dashs, no debería estar en cooldown
			hide_all_cooldown_indicators()

func hide_all_cooldown_indicators() -> void:
	dash_sprite_timer.hide()
	dash_sprite_timer_2.hide()

# Funciones para llamar desde el player
func start_dash_cooldown(dashes_available: int) -> void:
	update_dash_display(dashes_available, true)

func finish_dash_cooldown(dashes_available: int) -> void:
	update_dash_display(dashes_available, false)

func reset_dash_icons(max_dashes: int) -> void:
	hide_all_cooldown_indicators()
	update_dash_display(max_dashes, false)
