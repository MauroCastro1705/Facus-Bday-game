extends Node2D

# GameManager.gd - Sistema de gestión de habitaciones para twin stick shooter
const GAME_OVER:String = "res://escenas/Game_over/game_over.tscn"
@export var fade_duration: float = 0.5
signal room_changed(new_room: Node2D, room_index: int)
signal room_cleared(room_index: int)
@warning_ignore("unused_signal")
signal all_rooms_cleared()
signal player_is_in_room
signal enemy_died

@export var initial_room_index: int = 0
@export var rooms_parent: Node2D
@export var player: Node2D
@export var room_scenes: Array[PackedScene] = []

var current_room_index: int = -1
var current_room_instance: Node2D = null
var room_transitioning: bool = false
var room_data: Dictionary = {}

# Flag para controlar transiciones
var transitioning: bool = false
var pending_room_index: int = -1  # Para guardar la habitación pendiente durante la transición

# Referencia al TransitionManager (Autoload)
@onready var transition_manager: TransitionManager = get_node("/root/TransitionManager")

func _ready():
	if rooms_parent == null:
		rooms_parent = self
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if room_scenes.size() > 0:
		# Cargar la primera habitación usando el sistema de transiciones
		_switch_to_room(initial_room_index)

func _switch_to_room(room_index: int):
	if transitioning:
		push_warning("Ya hay una transición en curso")
		return
	
	if room_index < 0 or room_index >= room_scenes.size():
		push_error("Índice de habitación inválido: ", room_index)
		return
	
	transitioning = true
	pending_room_index = room_index
	
	# Usar el TransitionManager para la transición
	if transition_manager:
		# Conectar la señal scene_changed para saber cuándo termina la transición
		if not transition_manager.scene_changed.is_connected(_on_transition_complete):
			transition_manager.scene_changed.connect(_on_transition_complete)
		
		# Iniciar la transición (esto activa el efecto visual)
		transition_manager.change_scene("")  # Pasamos string vacío porque no cambiamos de escena
		
		# Esperar a que la transición de entrada termine
		await get_tree().create_timer(0.5).timeout  # La duración de la transición
		
		# Realizar el cambio de habitación
		_perform_room_change(room_index)
		
		# Completar la transición (efecto de salida)
		transition_manager._scene_changed_callback()
	else:
		# Fallback sin transición
		_perform_room_change(room_index)
		transitioning = false

func _perform_room_change(room_index: int):
	# Limpiar habitación actual
	if current_room_instance:
		disconnect_room_signals(current_room_instance)
		current_room_instance.queue_free()
		current_room_instance = null
		current_room_index = -1
	
	# Instanciar nueva habitación
	var room_scene = room_scenes[room_index]
	if room_scene == null:
		push_error("La habitación en el índice ", room_index, " es nula")
		transitioning = false
		return
	
	current_room_instance = room_scene.instantiate()
	rooms_parent.add_child(current_room_instance)
	current_room_index = room_index
	
	# Configurar la habitación
	setup_room(current_room_instance, room_index)
	
	# Posicionar al jugador
	position_player_in_room(current_room_instance)
	
	transitioning = false
	
	room_changed.emit(current_room_instance, room_index)
	print("Habitación ", room_index, " cargada")

func _on_transition_complete():
	"""Callback cuando la transición visual termina"""
	# Si hay una habitación pendiente, cargarla
	if pending_room_index >= 0:
		_perform_room_change(pending_room_index)
		pending_room_index = -1

func setup_room(room: Node2D, room_index: int):
	"""Configura la habitación después de instanciarla"""
	# Buscar áreas de transición
	var transition_areas = room.get_tree().get_nodes_in_group("room_transition")
	for area in transition_areas:
		if area is Area2D:
			# Desconectar cualquier señal previa
			if area.body_entered.is_connected(_on_transition_area_entered):
				area.body_entered.disconnect(_on_transition_area_entered)
			
			# Conectar con call_deferred para evitar problemas de flushing
			area.body_entered.connect(_on_transition_area_entered.bind(room_index))
	
	# Buscar enemigos
	var enemies = room.get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		for enemy in enemies:
			if enemy.has_signal("died") and not enemy.died.is_connected(_on_enemy_died):
				enemy.died.connect(_on_enemy_died.bind(room_index))
		
		room_data[room_index] = {
			"total_enemies": enemies.size(),
			"enemies_alive": enemies.size(),
			"cleared": false
		}
	else:
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
	
	# Buscar el spawn point
	var spawn_points = room.get_tree().get_nodes_in_group("player_spawn")
	if spawn_points.size() > 0:
		var spawn = spawn_points[0] as Node2D
		player.global_position = spawn.global_position
	else:
		# Si la habitación es de tipo RoomBase, usar su método
		if room.has_method("get_player_spawn_position"):
			player.global_position = room.get_player_spawn_position()
			print("vamos por aca!")
		else:
			player.global_position = room.global_position
	player_is_in_room.emit()

func disconnect_room_signals(room: Node2D):
	"""Desconecta todas las señales de la habitación"""
	if not room:
		return
	
	var transition_areas = room.get_tree().get_nodes_in_group("room_transition")
	for area in transition_areas:
		if area is Area2D and area.body_entered.is_connected(_on_transition_area_entered):
			area.body_entered.disconnect(_on_transition_area_entered)
	
	var enemies = room.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_signal("died") and enemy.died.is_connected(_on_enemy_died):
			enemy.died.disconnect(_on_enemy_died)

# ============= SEÑALES CON CALL_DEFERRED =============

func _on_transition_area_entered(body: Node2D, room_index: int):
	if body != player or transitioning:
		return
	
	# Verificar si la habitación está limpia
	if not is_room_cleared(room_index):
		print("¡Debes eliminar todos los enemigos primero!")
		# Mostrar mensaje de bloqueo
		if current_room_instance and current_room_instance is RoomBase:
			current_room_instance.show_blocked_message()
		return
	
	# Avanzar a la siguiente habitación usando el TransitionManager
	var next_room_index = room_index + 1
	if next_room_index < room_scenes.size():
		print("Avanzando a la habitación ", next_room_index, " con transición")
		_switch_to_room(next_room_index)
	else:
		print("¡Todas las habitaciones completadas!")
		all_rooms_cleared.emit()

func _on_enemy_died(room_index: int):
	"""Cuando un enemigo muere"""
	if room_data.has(room_index):
		room_data[room_index].enemies_alive -= 1
		enemy_died.emit()
		
		if room_data[room_index].enemies_alive <= 0:
			room_data[room_index].cleared = true
			print("¡Habitación ", room_index, " limpiada!")
			room_cleared.emit(room_index)
			
			# Notificar a la habitación si es RoomBase
			if current_room_instance and current_room_instance is RoomBase:
				current_room_instance.on_room_cleared()

# ============= FUNCIONES AUXILIARES =============

func get_current_room() -> Node2D:
	return current_room_instance

func get_current_room_index() -> int:
	return current_room_index

func is_room_cleared(room_index: int = -1) -> bool:
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].cleared
	return false

func get_room_enemies_alive(room_index: int = -1) -> int:
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].enemies_alive
	return 0

func get_room_total_enemies(room_index: int = -1) -> int:
	if room_index == -1:
		room_index = current_room_index
	
	if room_data.has(room_index):
		return room_data[room_index].total_enemies
	return 0

func restart_game():
	if transitioning:
		return
	
	room_data.clear()
	_switch_to_room(initial_room_index)

func _on_player_death():
	if transition_manager:
		# Usar el sistema de transiciones para ir al Game Over
		transition_manager.change_scene(GAME_OVER)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file(GAME_OVER)
