extends Control
@onready var enemies_remaining: Label = $MarginContainer/HBoxContainer/enemies_remaining
@onready var game_manager: Node2D = $"../../gameManager"
var enemigos_total:int = 0
var enemigos_left:int = 0


func _ready() -> void:
	game_manager.player_is_in_room.connect(signal_from_room)
	game_manager.enemy_died.connect(_enemy_died_update)

func _process(_delta: float) -> void:
	pass

func signal_from_room():
	enemigos_total = game_manager.get_room_total_enemies()
	enemigos_left = enemigos_total
	print ("estos son los enemigos : " , str(enemigos_total))
	enemies_remaining.text = "Enemies left: " + str(enemigos_left) + "/" + str(enemigos_total)

func _enemy_died_update():
	enemigos_left -= 1
	enemies_remaining.text = "Enemies left: " + str(enemigos_left) + "/" + str(enemigos_total)
