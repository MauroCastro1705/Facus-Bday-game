extends Node2D
#heal node para player
@onready var timer: Timer = $Timer
var player_in_zone: Node2D = null  # Guarda referencia al jugador en la zona
@export var heal_timer:float = 1.0 ##intervalo entre curaciones
@export var heal_amount:float = 20 ##cant de curacion
func _ready() -> void:
	timer.wait_time = heal_timer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = body
		heal_player(body)  ## Cura inmediatamente al entrar
		timer.start()      ## Inicia el timer para curas periódicas


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body == player_in_zone:
		player_in_zone = null
		timer.stop()   
	
func _on_timer_timeout() -> void:
	if player_in_zone and is_instance_valid(player_in_zone):
		heal_player(player_in_zone)
	else:
		timer.stop()
		player_in_zone = null


func heal_player(body: Node2D) -> void:
	if body.has_method("heal_player"):
		body.heal_player(heal_amount)
