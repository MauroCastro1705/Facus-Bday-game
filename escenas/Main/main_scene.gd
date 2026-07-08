extends Node2D
@onready var game_manager: Node2D = $gameManager

func _ready() -> void:
	game_manager.player = $Player  # Asignar referencia al jugador
	game_manager.room_changed.connect(_on_room_changed)
	game_manager.room_cleared.connect(_on_room_cleared)
	game_manager.all_rooms_cleared.connect(_on_game_completed)
	
	
func _on_room_changed(new_room: Node2D, room_index: int):
	pass #mostrar ui con numero de rooms

func _on_room_cleared(room_index: int):
	pass #mensaje de room clear
	
func _on_game_completed():
	pass #llevar a pantala victoria
