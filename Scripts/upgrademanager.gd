# UpgradeManager.gd (Autoload)
extends Node

signal upgrade_unlocked(upgrade_name: String)

var available_upgrades := {
	"buenas_bolas": {"text": "- Buenas Bolas", "unlocked": false},
	"cotocola": {"text": "- Cotocola", "unlocked": false}
}

func unlock_upgrade(upgrade_name: String) -> void:
	if available_upgrades.has(upgrade_name) and not available_upgrades[upgrade_name].unlocked:
		available_upgrades[upgrade_name].unlocked = true
		upgrade_unlocked.emit(upgrade_name)
