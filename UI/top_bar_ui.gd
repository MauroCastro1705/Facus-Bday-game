extends Control

@onready var enemies_remaining_label: Label = $MarginContainer/HBoxContainer/enemies_remaining
@onready var game_manager: Node2D = $"../../gameManager"
@onready var calavera: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var upgrade_1: Label = %upgrade_1
@onready var upgrade_2: Label = %upgrade_2
@onready var upgrade_3: Label = %upgrade_3

var upgrades_unlocked := []  # Para evitar duplicados
var enemigos_left:int = 0
func _ready() -> void:
	upgrade_1.hide()
	upgrade_2.hide()
	upgrade_3.hide()
	enemigos_left = Global.enemy_room_left
	# Conectar señales del game manager
	game_manager.player_is_in_room.connect(_on_player_entered_room)
	game_manager.enemy_died.connect(_on_enemy_died)
	
	# Conectar señal del UpgradeManager
	UpgradeManager.upgrade_unlocked.connect(_on_upgrade_unlocked)
	
	# Resetear UI
	_reset_ui()

func _reset_ui() -> void:
	calavera.show()
	enemies_remaining_label.text = "Enemies left: 0/0"
	upgrade_1.text = ""
	upgrade_2.text = ""
	upgrade_3.text = ""

func _on_player_entered_room() -> void:
	_update_enemies_label()

func _on_enemy_died() -> void:
	_update_enemies_label()
	enemigos_left = Global.enemy_room_left
	if enemigos_left == 0:
		enemies_remaining_label.text = "The portal is Open"
		calavera.hide()

func _update_enemies_label() -> void:
	enemies_remaining_label.text = "Enemies left: " + str(Global.enemy_room_left) + "/" + str(Global.enemy_room_count)
	print("enemigos totales: " , Global.enemy_room_count , "enemigos que quedan. ", Global.enemy_room_left)

func _on_upgrade_unlocked(upgrade_name: String) -> void:
	# Evitar duplicados
	if upgrade_name in upgrades_unlocked:
		return
	
	upgrades_unlocked.append(upgrade_name)
	
	# Obtener el texto de la mejora
	var upgrade_text = UpgradeManager.available_upgrades[upgrade_name].text
	
	# Asignar al primer label disponible
	if upgrade_1.text == "":
		upgrade_1.show()
		upgrade_1.text = upgrade_text
	elif upgrade_2.text == "":
		upgrade_2.show()
		upgrade_2.text = upgrade_text
	elif upgrade_3.text == "":
		upgrade_3.show()
		upgrade_3.text = upgrade_text
	else:
		print("No hay espacio para más mejoras")
