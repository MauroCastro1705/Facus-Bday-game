extends Control

@onready var coins: Label = %Label


func _ready() -> void:
	Global.stats_updated.connect(_update_coins)
	coins.text = str(Global.player_coins)

func _update_coins():
	coins.text = str(Global.player_coins)
