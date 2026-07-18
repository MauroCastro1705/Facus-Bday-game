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


var count1:int = 0
var count2:int = 0
var count3:int = 0
func _skill_1_comprada():#cotocola
	
	UpgradeManager.unlock_upgrade("cotocola")
	upgrade_buyed.play()
	Global.bullet_global_size += Vector2(1,1)
	count1 += 1
	boton_skill.skill_display_name = "Cotocola - " + str(count1)
	boton_skill.skill_price += 100
	boton_skill._update_ui()
	
func _skill_2_comprada():#buenas bolas
	UpgradeManager.unlock_upgrade("buenas_bolas")
	upgrade_buyed.play()
	count2 += 1
	boton_skill_2.skill_display_name = "Buenas Bolas - " + str(count2)
	Global.playerAtkDmg += 10
	boton_skill_2.skill_price += 100
	boton_skill_2._update_ui()
	
func _skill_3_comprada():
	UpgradeManager.unlock_upgrade("bullterrier")
	upgrade_buyed.play()
	count3 += 1
	boton_skill_3.skill_display_name = "Bullterrier - " + str(count3)
	Global.playerAmmo += 5
	boton_skill_3.skill_price += 100
	boton_skill_3._update_ui()
