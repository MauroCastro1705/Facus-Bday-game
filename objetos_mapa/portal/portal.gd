extends Node2D
@onready var luz_portal: PointLight2D = $luz_portal
@onready var portal_msg: Label = $portal_msg
const OK_COLOR:Color = Color(0.0, 0.678, 0.757)
const BAD_COLOR:Color = Color(1.0, 0.188, 0.259)
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	portal_msg.hide()
	gpu_particles_2d.hide()

func portal_luz_mala():
	luz_portal.color = BAD_COLOR
	
func portal_luz_ok():
	luz_portal.color = OK_COLOR
	gpu_particles_2d.show()
	gpu_particles_2d.emitting = true

func show_mensaje():
	portal_msg.show()
	portal_msg.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(portal_msg, "modulate:a", 0.0, 1.5).set_delay(1.0)
	tween.tween_callback(portal_msg.hide)
