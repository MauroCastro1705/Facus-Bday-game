extends Node2D

@onready var texto_indio: Label = $texto/texto_indio
@onready var player_detection: Area2D = $player_detection
@onready var nine_patch_rect: NinePatchRect = $texto/NinePatchRect


func _ready() -> void:
	texto_indio.hide()
	nine_patch_rect.hide()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		texto_indio.show()
		nine_patch_rect.show()


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		texto_indio.hide()
		nine_patch_rect.hide()
		texto_indio.text = "hola soy el indio"

var texto_indice = 0

func change_text() -> void:
	if not texto_indio:
		return
	
	texto_indice += 1
	
	match texto_indice:
		1:
			texto_indio.text = "¡Nene-nena! ¡Nene-nena! ¡Nene-nena!
¡Nene-nena! ¡Nena-uh"
		2:
			texto_indio.text = "Tirale a esas estatuas, algo te van a ayudar"
		3:
			texto_indio.text = "VIVIR SOLO CUESTA BIRRA"
		_:
			texto_indice = 0
			texto_indio.text = "que tiras tiros gil, tomatela!"
