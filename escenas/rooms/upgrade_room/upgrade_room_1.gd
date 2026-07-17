extends Node2D
@onready var boton_skill: SkillPurchaseStation = $boton_skill
@onready var boton_skill_2: SkillPurchaseStation = $boton_skill2


func _ready():
	boton_skill.purchase_completed.connect(_skill_1_comprada)
	boton_skill_2.purchase_completed.connect(_skill_2_comprada)



func _skill_1_comprada():#cotocola
	UpgradeManager.unlock_upgrade("cotocola")
	Global.bullet_global_size = Vector2(2,2)
	
func _skill_2_comprada():#buenas bolas
	UpgradeManager.unlock_upgrade("buenas_bolas")
	Global.playerAtkDmg += 10
