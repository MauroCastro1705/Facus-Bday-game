extends Area2D
var travelled_distance = 0
@export var bullet_dmg:float = 10
@export var SPEED:int = 250


const IMPACT_PARTICLES  = preload("res://pistol/impact/impactParticle.tscn")

func _physics_process(delta):
	
	var RANGE = Global.bulletRange
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("paredes"):
		_spawn_impact()
		queue_free()
	
	if body.has_method("take_damage"):
		_spawn_impact()
		queue_free()
		body.take_damage(bullet_dmg)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("paredes"):
		_spawn_impact()
		queue_free()

func _spawn_impact():
	var impact = IMPACT_PARTICLES.instantiate()
	get_tree().current_scene.add_child(impact)
	impact.global_position = global_position
