extends Node

# ImpactParticlePool.gd (autoload o nodo manager)
const IMPACT_PARTICLES = preload("res://pistol/impact/impactParticle.tscn")
const POOL_SIZE = 10

##se usa asi ImpactParticlePool.spawn_impact(global_position)

var pool: Array[GPUParticles2D] = []
var index = 0

func _ready():
	for i in POOL_SIZE:
		var p = IMPACT_PARTICLES.instantiate()
		p.emitting = false
		add_child(p)
		pool.append(p)

func spawn_impact(pos: Vector2):
	var p = pool[index]
	p.global_position = pos
	p.restart()
	index = (index + 1) % POOL_SIZE
	print("particula mostrada")
