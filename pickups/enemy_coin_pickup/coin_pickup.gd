extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pick_up_sound: AudioStreamPlayer2D = $pick_up_sound

func _ready() -> void:
	animation_player.play("coin")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_coins += 10
		pick_up_sound.play()
		await pick_up_sound.finished
		Global.emit_signal("stats_updated")
		queue_free()
	
