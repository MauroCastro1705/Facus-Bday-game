extends Area2D
var travelled_distance = 0
var bullet_dmg:float = 10

func _physics_process(delta):
	var SPEED = Global.bulletSpeed
	var RANGE = Global.bulletRange
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("paredes"):
		queue_free()
	
	if body.has_method("take_damage"):
		queue_free()
		body.take_damage(bullet_dmg)
