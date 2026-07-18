extends Node2D
class_name RoomBase
#ROOM 1
@onready var portal: Node2D = $Props/Portal



# Señales que pueden ser útiles
signal room_entered()
signal room_exited()
signal room_cleared()
signal enemies_changed(enemies_alive: int, total_enemies: int)


# Variables exportadas para personalizar cada habitación
@export var room_name: String = "Habitación"
@export var room_id: int = 0
@export var requires_clear: bool = true  # Si necesita limpiar enemigos para avanzar
@export var spawn_enemies_on_enter: bool = true

# Referencias a nodos importantes
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var transition_area: Area2D = $Transition_area
@onready var enemies_container: Node2D = $EnemiesContainer
@onready var props_container: Node2D = $Props

# Estado interno
var enemies_alive: int = 0
var total_enemies: int = 0
var is_cleared: bool = false
var is_active: bool = false

func _ready():
	portal.portal_msg.hide()
	portal.portal_luz_mala()
	# Configurar transición
	if transition_area:
		transition_area.body_entered.connect(_on_transition_area_body_entered)
		transition_area.body_exited.connect(_on_transition_area_body_exited)
	
	# Contar enemigos iniciales
	count_enemies()
	
	# Si no debe spawnear enemigos al entrar, desactivarlos inicialmente
	if not spawn_enemies_on_enter:
		set_enemies_active(false)

func _on_transition_area_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if can_exit_room():
			room_exited.emit()
		else:
			show_blocked_message()

func _on_transition_area_body_exited(body: Node2D):
	if body.is_in_group("player"):
		room_entered.emit()

func can_exit_room() -> bool:
	#Verifica si se puede salir de la habitación"""
	if requires_clear:
		return is_cleared
	return true

func show_blocked_message():
	print("Room base : Debes eliminar todos los enemigos primero" , "se limpio? :" ,  is_cleared)
	portal.show_mensaje()

# ============= FUNCIONES DE ENEMIGOS =============

func count_enemies():
	total_enemies = 0
	enemies_alive = 0
	if enemies_container:
		# Buscar enemigos en el contenedor y en toda la escena
		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy.get_parent() == enemies_container or is_descendant_of(enemy, enemies_container):
				total_enemies += 1
				enemies_alive += 1
				
				# Conectar señal de muerte
				if enemy.has_signal("died"):
					if not enemy.died.is_connected(_on_enemy_died):
						enemy.died.connect(_on_enemy_died)
	# Si no hay enemigos, la habitación está limpia
	Global.enemy_room_count = total_enemies
	Global.enemy_room_left = enemies_alive
	if enemies_alive == 0:
		is_cleared = true
		room_cleared.emit()

	print("enemigos totales room 1. " , total_enemies)
	enemies_changed.emit(enemies_alive, total_enemies)

func _on_enemy_died():
	enemies_alive -= 1
	Global.enemy_room_left -= 1
	enemies_changed.emit(enemies_alive, total_enemies)
	
	if enemies_alive <= 0:
		is_cleared = true
		room_cleared.emit()
		on_room_cleared()

func on_room_cleared():
	# Abrir puertas, mostrar mensaje, etc.
	print("¡Habitación ", room_name, " limpiada!")
	# Ejemplo: abrir puertas visualmente
	portal.portal_luz_ok()
	open_doors()
	can_exit_room()
	is_cleared = true

func set_enemies_active(active: bool):
	"""Activa o desactiva todos los enemigos de la habitación"""
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy.has_method("set_active"):
				enemy.set_active(active)

func spawn_enemies():
	"""Spawnear enemigos (si están desactivados inicialmente)"""
	if spawn_enemies_on_enter:
		set_enemies_active(true)

func is_descendant_of(node: Node, ancestor: Node) -> bool:
	"""Verifica si un nodo es descendiente de otro"""
	var current = node
	while current:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false

# ============= FUNCIONES DE PUERTAS (opcional) =============

func open_doors():
	"""Abre las puertas de la habitación"""
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.has_method("open"):
			door.open()

func close_doors():
	"""Cierra las puertas de la habitación"""
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.has_method("close"):
			door.close()

# ============= FUNCIONES DE SPAWN DEL JUGADOR =============

func get_player_spawn_position() -> Vector2:
	"""Retorna la posición de spawn del jugador"""
	if spawn_point:
		return spawn_point.global_position
	return global_position

# ============= FUNCIONES DE RESET =============

func reset_room():
	"""Reinicia la habitación a su estado inicial"""
	is_cleared = false
	enemies_alive = total_enemies
	
	# Resetear enemigos
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy.has_method("reset"):
				enemy.reset()
	
	# Cerrar puertas
	close_doors()
	
	enemies_changed.emit(enemies_alive, total_enemies)

# ============= FUNCIONES DE DEBUG =============

func get_room_info() -> String:
	"""Retorna información de la habitación para debug"""
	return "Room: %s | ID: %d | Enemies: %d/%d | Cleared: %s" % [
		room_name, room_id, enemies_alive, total_enemies, str(is_cleared)
	]
