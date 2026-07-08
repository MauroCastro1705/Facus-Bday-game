extends RoomBase


func _ready():
	# Llamar al _ready del padre
	super._ready()
	
	# Configuraciones específicas
	room_name = "Sala de Inicio numero 2 CUSTOM"
	room_id = 1
	
func on_room_cleared():
	# Sobrescribir el método de la habitación base
	super.on_room_cleared()
	
	
	# Spawnear cofre o recompensa
#	spawn_reward()

#func spawn_reward():
#	# Crear un cofre o recompensa
#	var reward_scene = preload("res://items/reward_chest.tscn")
#	if reward_scene:
#		var reward = reward_scene.instantiate()
#		add_child(reward)
#		reward.global_position = $RewardSpawn.global_position

func _on_transition_area_body_entered(body: Node2D):
	# Lógica adicional al entrar en el área de transición
	print("Jugador cerca de la salida de la habitación CUSTOM")
	super._on_transition_area_body_entered(body)
