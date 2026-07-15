extends StaticBody2D
class_name SkillPurchaseStation
@onready var hover_area: Area2D = $Area2D

# ===== NODOS =====
@onready var skill_name: Label = %name
@onready var texto_skill: Label = %texto_skill
@onready var price: Label = %price
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texto_hover: NinePatchRect = $texto_hover

# ===== VARIABLES EXPORTADAS PARA EDITAR DESDE EL EDITOR =====
@export_group("Skill Configuration")
@export var skill_display_name: String = "Nueva Habilidad"
@export var skill_description: String = "Descripción de la habilidad"
@export var skill_price: int = 100
@export var skill_icon_texture: Texture2D

@export_group("Purchase Settings")
@export var can_purchase_multiple_times: bool = false
@export var max_purchases: int = 1
@export var skill_id: String = ""  # Identificador único

@export_group("Visual Feedback")
@export var purchase_color: Color = Color(0.2, 0.8, 0.2, 1)
@export var error_color: Color = Color(0.8, 0.2, 0.2, 1)
@export var default_color: Color = Color(1, 1, 1, 1)

# ===== VARIABLES INTERNAS =====
var current_purchases: int = 0
var is_purchased: bool = false
var original_price: int = 0
var is_on_cooldown: bool = false
var purchase_cooldown: float = 0.5

# ===== SEÑALES =====
signal purchase_attempted(success: bool, skill_id: String)
signal purchase_completed(skill_id: String)

func _ready() -> void:
	# Guardar precio original para reset
	original_price = skill_price
	texto_hover.hide()
	# Configurar UI
	_update_ui()
	
	# Configurar estado inicial
	_update_visual_state()
	

func _update_ui() -> void:
	"""Actualiza todos los elementos visuales del botón"""
	if skill_name:
		skill_name.text = skill_display_name
	
	if texto_skill:
		texto_skill.text = skill_description
		
	if price:
		price.text = "$" + str(skill_price)

func _update_visual_state() -> void:
	"""Actualiza el estado visual basado en compras y disponibilidad"""
	
	if is_purchased and not can_purchase_multiple_times:
		# Ya comprado (habilidad única)
		modulate = Color(0.5, 0.5, 0.5, 1)
		if price:
			price.text = "¡COMPRADO!"
		if skill_name:
			skill_name.modulate = Color(0.8, 0.8, 0.8, 1)
		return
	
	if current_purchases >= max_purchases and not can_purchase_multiple_times:
		# Alcanzó el máximo de compras
		modulate = Color(0.5, 0.5, 0.5, 1)
		if price:
			price.text = "¡COMPRADO!"
		return
	
	# Estado normal - disponible para comprar
	modulate = default_color
	if price:
		price.text = "$" + str(skill_price)

# ===== FUNCIÓN PRINCIPAL DE COMPRA =====
func try_purchase() -> bool:
	"""
	Intenta comprar la habilidad
	Retorna: true si se compró exitosamente, false si no
	"""
	
	# Validaciones
	if not _can_purchase():
		return false
	
	# Verificar si el jugador tiene suficientes monedas
	if not _has_enough_coins():
		_show_error_feedback("¡No tienes suficientes monedas!")
		emit_signal("purchase_attempted", false, skill_id)
		return false
	
	# Ejecutar compra
	_execute_purchase()
	return true

func _can_purchase() -> bool:
	"""Verifica si se puede comprar la habilidad"""
	
	# Verificar si ya está comprada (habilidad única)
	if is_purchased and not can_purchase_multiple_times:
		_show_error_feedback("¡Ya compraste esta habilidad!")
		return false
	
	# Verificar límite de compras
	if current_purchases >= max_purchases and not can_purchase_multiple_times:
		_show_error_feedback("¡Límite de compras alcanzado!")
		return false
	
	# Verificar cooldown
	if is_on_cooldown:
		_show_error_feedback("Espera un momento")
		return false
	
	return true

func _has_enough_coins() -> bool:
	"""Verifica si el jugador tiene suficientes monedas"""
	if not has_node("/root/Global"):
		push_error("Nodo Global no encontrado")
		return false
	
	return Global.player_coins >= skill_price

func _execute_purchase() -> void:
	"""Ejecuta la compra y actualiza todo"""
	
	# 1. Deducir monedas
	Global.player_coins -= skill_price
	
	# 2. Incrementar contador
	current_purchases += 1
	
	# 3. Marcar como comprado si es habilidad única
	if not can_purchase_multiple_times:
		is_purchased = true
	
	# 4. Emitir señales
	Global.emit_signal("stats_updated")
	emit_signal("purchase_completed", skill_id)
	emit_signal("purchase_attempted", true, skill_id)
	
	# 5. Feedback visual
	_show_success_feedback()
	# 8. Actualizar UI
	_update_visual_state()
	
	# 9. Iniciar cooldown
	_start_cooldown()
	
	# 10. Imprimir información
	print("[Skill] Compra exitosa: ", skill_display_name, " (ID: ", skill_id, ")")
	print("[Skill] Compras totales: ", current_purchases, "/", max_purchases)



func _show_success_feedback() -> void:
	"""Muestra efecto de compra exitosa"""
	modulate = purchase_color
	
	# Efecto de escala
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	
	# Restaurar color después de un tiempo
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_update_visual_state)

func _show_error_feedback(message: String) -> void:
	"""Muestra efecto de error"""
	print("[Skill] Error: ", message)
	
	# Cambiar color a rojo
	modulate = error_color
	
	# Efecto de vibración
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", position - Vector2(10, 0), 0.05)
	tween.tween_property(self, "position", position + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", position, 0.05)
	
	# Restaurar color
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_update_visual_state)
	


func _start_cooldown() -> void:
	"""Inicia cooldown para evitar compras múltiples accidentales"""
	if purchase_cooldown > 0:
		is_on_cooldown = true
		var timer = get_tree().create_timer(purchase_cooldown)
		timer.timeout.connect(func(): 
			is_on_cooldown = false
			print("[Skill] Cooldown terminado")
		)

# ===== FUNCIONES DE UTILIDAD =====

func reset_purchase() -> void:
	"""Reinicia el estado de compra (útil para testing)"""
	current_purchases = 0
	is_purchased = false
	skill_price = original_price
	_update_visual_state()
	print("[Skill] Reset completado: ", skill_display_name)

func set_price(new_price: int) -> void:
	"""Cambia el precio dinámicamente"""
	skill_price = new_price
	if price:
		price.text = "$" + str(new_price)

func get_purchase_count() -> int:
	"""Retorna cuántas veces se compró"""
	return current_purchases

func is_fully_purchased() -> bool:
	"""Verifica si ya no se puede comprar más"""
	return current_purchases >= max_purchases or is_purchased

func highlight_purchase() -> void:
	"""Efecto de resaltado para indicar que se puede comprar"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate", Color(1, 1, 0.5, 1), 0.5)
	tween.tween_property(self, "modulate", default_color, 0.5)

# ===== MÉTODOS PARA INTERACCIÓN CON EL JUGADOR =====

# Si quieres que el jugador pueda comprar presionando "E" cerca
func _on_interaction_area_body_entered(body: Node) -> void:
	"""Cuando el jugador entra en el área de interacción"""
	if body.is_in_group("player"):
		highlight_purchase()

func _on_interaction_area_body_exited(body: Node) -> void:
	"""Cuando el jugador sale del área de interacción"""
	if body.is_in_group("player"):
		_update_visual_state()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		texto_hover.show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		texto_hover.hide()
