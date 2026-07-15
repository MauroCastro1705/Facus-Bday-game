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

func change_text() -> void:
	texto_indio.text = "que tiras tiros gil, tomatela!"
