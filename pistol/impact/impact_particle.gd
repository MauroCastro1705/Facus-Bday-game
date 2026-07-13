extends GPUParticles2D
#particula de impacto para los enemigos

func _ready():
	emitting = true
	# buffer de seguridad además del lifetime real
	await get_tree().create_timer(lifetime + 0.2).timeout
	queue_free()
