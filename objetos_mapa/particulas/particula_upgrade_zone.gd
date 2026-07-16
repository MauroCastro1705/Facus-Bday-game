extends GPUParticles2D

@export var wind_power: float = 1.0
@export var wind_frequency: float = 0.5
@export var rotation_speed: float = 0.02
@export var scale_pulse: float = 0.1
@export var min_scale: float = 0.9
@export var max_scale: float = 1.1

var base_direction = Vector3(0.3, 0.7, 0.0)  # Cambiado a Vector3
var time = 0.0

func _ready():
	# Duplicar el material para no modificar el original
	process_material = process_material.duplicate()
	
	# Configuración inicial
	emitting = true

func _process(delta: float) -> void:
	time += delta
	
	# Rotación suave de la zona de partículas
	rotation = sin(time * rotation_speed) * 0.05
	
	# Efecto de respiración en la escala
	var scale_factor = 1.0 + sin(time * 0.8) * scale_pulse
	scale = Vector2(
		clamp(scale_factor, min_scale, max_scale),
		clamp(scale_factor, min_scale, max_scale)
	)
	
	# Simular ráfagas de viento
	if process_material:
		var wind_strength = 1.0 + sin(time * wind_frequency) * 0.3
		var wind_angle = sin(time * 0.2) * 0.15
		
		# Cambiar dirección suavemente (usando Vector3)
		var direction = base_direction.rotated(Vector3(0, 0, 1), wind_angle)
		direction = direction.normalized() * wind_strength
		
		# Asignar correctamente como Vector3
		process_material.direction = direction
		
		# Variar velocidad con el viento
		process_material.initial_velocity_min = 15.0 * wind_strength
		process_material.initial_velocity_max = 35.0 * wind_strength

func create_wind_gust():
	# Efecto de ráfaga de viento
	amount = 100
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func():
		amount = 50
		timer.queue_free()
	)
	timer.start()
