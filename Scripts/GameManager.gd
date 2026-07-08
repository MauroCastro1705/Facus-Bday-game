extends Node2D

# GameManager.gd - Sistema de gestión de habitaciones para twin stick shooter

# Señales para comunicación con otros sistemas
signal room_changed(new_room: Node2D, room_index: int)
signal room_cleared(room_index: int)
signal all_rooms_cleared()

# Variables de configuración
@export var initial_room_index: int = 0
@export var rooms_parent: Node2D  # Nodo padre donde se instanciarán las habitaciones
@export var player: Node2D  # Referencia al jugador

# Lista de habitaciones (PackedScene)
@export var room_scenes: Array[PackedScene] = []

# Estado interno
var current_room_index: int = -1
var current_room_instance: Node2D = null
var room_transitioning: bool = false

# Diccionario para almacenar datos de cada habitación
var room_data: Dictionary = {}

func _ready():
	if rooms_parent == null:
		rooms_parent = self  # Usar el propio GameManager como padre si no se especifica
	
	if player == null:
		# Buscar al jugador automáticamente
		player = get_tree().get_first_node_in_group("player")
	
	# Inicializar la primera habitación
	if room_scenes.size() > 0:
		load_room(initial_room_index)

# ============= FUNCIONES PRINCIPALES =============

func load_room(room_index: int):
	"""Carga una habitación específica por su índice"""
	if room_transitioning:
		push_warning("Ya hay una transición en curso")
		return
	
	if room_index < 0 or room_index >= room_scenes.size():
		push_error("Índice de habitación inválido: ", room_index)
		return
	
	room_transitioning = true
	
	# Limpiar habitación actual
	clear_current_room()
	
	# Instanciar nueva habitación
	var room_scene = room_scenes[room_index]
	if room_scene == null:
		push_error("La habitación en el índice ", room_index, " es nula")
		room_transitioning = false
		return
	
	current_room_instance = room_scene.instantiate()
	rooms_parent.add_child(current_room_instance)
	current_room_index = room_index
	
	# Configurar la habitación
	setup_room(current_room_instance, room_index)
	
	# Posicionar al jugador en el spawn de la habitación
	position_player_in_room(current_room_instance)
	
	room_transitioning = false
	
	# Emitir señal de cambio de habitación
	room_changed.emit(current_room_instance, room_index)
	print("Habitación ", room_index, " cargada")

func clear_current_room():
	"""Elimina la habitación actual y limpia sus recursos"""
	if current_room_instance:
		# Desconectar señales antes de eliminar
		disconnect_room_signals(current_room_instance)
		
		# Eliminar la habitación
		current_room_instance.queue_free()
		current_room_instance = null
		current_room_index = -1

func setup_room(room: Node2D, room_index: int):
	"""Configura la habitación después de instanciarla"""
	# Buscar el Area2D de transición y conectar su señal
	var transition_areas = room.get_tree().get_nodes_in_group("room_transition")
	for area in transition_areas:
		if area is Area2D:
			if not area.body_entered.is_connected(_on_transition_area_entered):
				area.body_entered.connect(_on_transition_area_entered.bind(room_index))
	
	# Buscar enemigos y conectar señales para detectar cuando la habitación esté limpia
	var enemies = room.get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		for enemy in enemies:
			if enemy.has_signal("died") and not enemy.died.is_connected(_on_enemy_died):
				enemy.died.connect(_on_enemy_died.bind(room_index))
		
		# Guardar cantidad de enemigos para saber cuándo limpiar la habitación
		room_data[room_index] = {
			"total_enemies": enemies.size(),
			"enemies_alive": enemies.size(),
			"cleared": false
		}
	else:
		# Si no hay enemigos, la habitación está limpia automáticamente
		room_data[room_index] = {
			"total_enemies": 0,
			"enemies_alive": 0,
			"cleared": true
		}
		room_cleared.emit(room_index)

func position_player_in_room(room: Node2D):
	"""Posiciona al jugador en el spawn point de la habitación"""
	if player == null:
		push_warning("No se encontró referencia al jugador")
		return
	
	# Buscar el spawn point en la habitación
	var spawn_points = room.get_tree().get_nodes_in_group("player_spawn")
	if spawn_points.size() > 0:
		var spawn = spawn_points[0] as Node2D
		player.global_position = spawn.global_position
	else:
		# Si no hay spawn point, posicionar en el centro de la habitación
		# o en la posición relativa al room
		player.global_position = room.global_position

func disconnect_room_signals(room: Node2D):
	"""Desconecta todas las señales de la habitación"""
	var transition_areas = room.get_tree().get_nodes_in_group("room_transition")
	for area in transition_areas:
		if area is Area2D and area.body_entered.is_connected(_on_transition_area_entered):
			area.body_entered.disconnect(_on_transition_area_entered)
	
	var enemies = room.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_signal("died") and enemy.died.is_connected(_on_enemy_died):
			enemy.died.disconnect(_on_enemy_died)

# ============= SEÑALES =============

func _on_transition_area_entered(body: Node2D, room_index: int):
	"""Cuando el jugador entra al área de transición"""
	if body == player and not room_transitioning:
		var next_room_index = room_index + 1
		
		# Verificar si la habitación actual está limpia
		if room_data.has(room_index) and room_data[room_index].cleared:
			if next_room_index < room_scenes.size():
				load_room(next_room_index)
			else:
				# No hay más habitaciones
				all_rooms_cleared.emit()
				print("¡Todas las habitaciones completadas!")
		else:
			print("Debes eliminar todos los enemigos antes de avanzar")

func _on_enemy_died(room_index: int):
	"""Cuando un enemigo muere, actualiza el contador de la habitación"""
	if room_data.has(room_index):
		room_data[room_index].enemies_alive -= 1
		
		if room_data[room_index].enemies_alive <= 0:
			room_data[room_index].cleared = true
			room_cleared.emit(room_index)
			print("¡Habitación ", room_index, " limpiada!")

# ============= FUNCIONES AUXILIARES =============

func get_current_room() -> Node2D:
	"""Retorna la instancia actual de la habitación"""
	return current_room_instance

func get_current_room_index() -> int:
	"""Retorna el índice de la habitación actual"""
	return current_room_index

func is_room_cleared(room_index: int = -1) -> bool:
	"""Verifica si una habitación está limpia"""
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].cleared
	return false

func get_room_enemies_alive(room_index: int = -1) -> int:
	"""Obtiene la cantidad de enemigos vivos en una habitación"""
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].enemies_alive
	return 0

func get_room_total_enemies(room_index: int = -1) -> int:
	"""Obtiene el total de enemigos en una habitación"""
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].total_enemies
	return 0

func add_room_after_index(index: int, room_scene: PackedScene):
	"""Agrega una nueva habitación después de un índice específico"""
	if index >= 0 and index <= room_scenes.size():
		room_scenes.insert(index + 1, room_scene)
	else:
		room_scenes.append(room_scene)

func remove_room_at_index(index: int):
	"""Elimina una habitación por su índice"""
	if index >= 0 and index < room_scenes.size():
		room_scenes.remove_at(index)
		# Limpiar datos de la habitación si existe
		if room_data.has(index):
			room_data.erase(index)
		# Si la habitación actual es la que se eliminó, recargar
		if current_room_index == index:
			load_room(clamp(index, 0, room_scenes.size() - 1))

func restart_game():
	"""Reinicia el juego desde la primera habitación"""
	clear_current_room()
	room_data.clear()
	load_room(initial_room_index)
