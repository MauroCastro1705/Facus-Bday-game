extends Node2D

var GameScore = 0
var gameTimer = 0

@onready var labelTiempo = %TiempoAlJefe
@onready var timerTiempoJefe = %TimerTiempoAlJefe
var time_left = 1 * 60  # 8 minutos en segundos

# En tu escena principal
var game_manager: GameManager

func _ready():
	Global.isLevelUpCompleted = true
	GameScore = 0
	get_tree().paused = false
	Global.HealthCoinsOnScreen = 0
	Global.SpeedCoinsOnScreen = 0
	Global.AtkSpeedCoinsOnScreen = 0
	set_process_unhandled_input(true)  # Habilita la entrada en pausa
	timerTiempoJefe.start()
	game_manager = $GameManager
	game_manager.player = $Player  # Asignar referencia al jugador
	game_manager.room_scenes = []
	game_manager.rooms_parent = $RoomsContainer  # Nodo donde se instanciarán

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused

func _physics_process(_delta):
	Global.MOB_DAMAGE()


func update_labelTiempo():
	var minutes = float(time_left) / 60
	var seconds = time_left % 60
	labelTiempo.text = "%02d:%02d" % [minutes, seconds]  # Formato MM:SS


func _on_player_health_depleted():
	get_tree().change_scene_to_file("res://game_over.tscn")
