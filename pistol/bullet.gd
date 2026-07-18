extends Area2D
var travelled_distance = 0
var bullet_dmg:float
@export var SPEED:int = 250
@onready var hit_sound: AudioStreamPlayer2D = $hit_sound
@onready var bullet: Area2D = $"."

const IMPACT_PARTICLES = preload("res://pistol/impact/impactParticle.tscn")

func _ready() -> void:
	bullet.scale = Global.bullet_global_size

func _physics_process(delta):
	bullet.scale = Global.bullet_global_size
	var RANGE = Global.bulletRange
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("indio"):
		body.change_text()
		_handle_hit(body)
	
	if body.is_in_group("skill") and body.has_method("try_purchase"):
		print("bala intento comprar")
		body.try_purchase()
		_handle_hit(body)
	
	if body.is_in_group("paredes"):
		_handle_hit()
	
	if body.has_method("take_damage"):
		bullet_dmg = Global.playerAtkDmg
		_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("paredes"):
		_handle_hit()

func _handle_hit(body = null):
	hit_sound.play()
	_spawn_impact()
	# Aplicar daño si existe
	if body and body.has_method("take_damage"):
		body.take_damage(bullet_dmg)
	hide()
	set_process(false)
	set_physics_process(false)
	await hit_sound.finished
	queue_free()

func _spawn_impact():
	var impact = IMPACT_PARTICLES.instantiate()
	get_tree().current_scene.add_child(impact)
	impact.global_position = global_position
