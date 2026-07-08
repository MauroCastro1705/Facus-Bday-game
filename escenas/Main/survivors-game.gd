extends Node2D

var GameScore = 0
var gameTimer = 0

@onready var labelTiempo = %TiempoAlJefe
@onready var timerTiempoJefe = %TimerTiempoAlJefe
var time_left = 1 * 60  # 8 minutos en segundos

func _ready():
	Global.isLevelUpCompleted = true
	GameScore = 0
	LABELS_update()
	get_tree().paused = false
	Global.HealthCoinsOnScreen = 0
	Global.SpeedCoinsOnScreen = 0
	Global.AtkSpeedCoinsOnScreen = 0
	set_process_unhandled_input(true)  # Habilita la entrada en pausa
	timerTiempoJefe.start()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused

func _physics_process(_delta):
	Global.MOB_DAMAGE()


func update_labelTiempo():
	var minutes = float(time_left) / 60
	var seconds = time_left % 60
	labelTiempo.text = "%02d:%02d" % [minutes, seconds]  # Formato MM:SS



func incrementar_dificultad():
	var dificultad = Global.playerLEVEL
	if dificultad == 9:
		%MobTimer.wait_time = 0.4
		show_alert("!Los Enemigos vienen mas rapido!")
	if dificultad == 16:
		%MobTimer.wait_time = 0.3
		show_alert("!Los Enemigos vienen aun mas rapido!")
	if dificultad == 21:
		%MobTimer.wait_time = 0.2
		show_alert("!Los Enemigos vienen muchisimo mas rapido!")
		
func show_alert(msg: String):
	%MobSpawnAlert.text = msg
	%MobSpawnAlert.visible = true
	await get_tree().create_timer(3).timeout
	%MobSpawnAlert.visible = false	





func Score_increment(points: int):
	var ScoreMult = Global.scoreMulti #revisar esto	
	GameScore += points * ScoreMult
	Global.playerScore = GameScore
	LABELS_update()

func _on_coin_timer_timeout() -> void:
	spaw_health_coins()
	spaw_speed_coins()
	spawn_atk_speed_coins()

#tree spawner
func _on_tree_timer_timeout() -> void:	
	# Lista de escenas a elegir
	var items = [
		preload("res://Pinetree.tscn"),
		preload("res://rock_1.tscn"),
		preload("res://rock_2.tscn"),
		preload("res://rock_3.tscn")
	]	
	# Seleccionar un item aleatorio
	var random_item = items[randi() % items.size()].instantiate()
	
	# Posicionar el item en un punto aleatorio del camino
	camino.progress_ratio = randf()
	random_item.global_position = camino.global_position
	
	# Agregar el item a la escena
	add_child(random_item)

func _on_player_health_depleted():
	get_tree().change_scene_to_file("res://game_over.tscn")

func LLEGA_EL_JEFE() -> void:
	clear_enemies()
	spawn_big_mob_BOSS()
	print("jefe")
	%MobTimer.paused = true
	%BigBossTimer.paused = true

func _on_timer_tiempo_al_jefe_timeout() -> void:
	if time_left > 0:
		time_left -= 1
		update_labelTiempo()
	else:
		timerTiempoJefe.stop()  # Detener el Timer
		labelTiempo.text = "Encuentro con el jefe"  # Cambiar mensaje
		labelTiempo.add_theme_color_override("font_color", Color.RED)  # Asegurar color rojo
		LLEGA_EL_JEFE()
