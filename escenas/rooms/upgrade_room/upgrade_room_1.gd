extends Node2D
@onready var boton_skill: SkillPurchaseStation = $boton_skill
@onready var boton_skill_2: SkillPurchaseStation = $boton_skill2



func _ready():
	boton_skill.purchase_completed.connect(_skill_1_comprada)
	boton_skill_2.purchase_completed.connect(_skill_2_comprada)



func _skill_1_comprada():#cotocola
	pass
	
func _skill_2_comprada():#buenas bolas
	Global.playerAtkDmg += 5
