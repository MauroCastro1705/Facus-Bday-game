extends Node2D
@onready var boton_skill: SkillPurchaseStation = $boton_skill
@onready var boton_skill_2: SkillPurchaseStation = $boton_skill2
@onready var upgrade_buyed: AudioStreamPlayer2D = $upgrade_buyed
@onready var boton_skill_3: SkillPurchaseStation = $boton_skill3

@export var room_name: String = "Pasillo loco"
@export var room_id: int = 0
@export var requires_clear: bool = true  # Si necesita limpiar enemigos para avanzar
@export var spawn_enemies_on_enter: bool = true


func _ready():
	boton_skill.purchase_completed.connect(_skill_1_comprada)
	boton_skill_2.purchase_completed.connect(_skill_2_comprada)
	boton_skill_3.purchase_completed.connect(_skill_3_comprada)



func _skill_1_comprada():#cotocola
	UpgradeManager.unlock_upgrade("cotocola")
	upgrade_buyed.play()
	Global.bullet_global_size = Vector2(2,2)
	
func _skill_2_comprada():#buenas bolas
	UpgradeManager.unlock_upgrade("buenas_bolas")
	upgrade_buyed.play()
	Global.playerAtkDmg += 10
	
func _skill_3_comprada():
	UpgradeManager.unlock_upgrade("buenas_bolas")
	upgrade_buyed.play()
