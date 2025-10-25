extends Node2D

#@onready var slime = get_node("Slime")
#@onready var slime_animation = get_node("Slime/AnimationPlayer")
##
@onready var dude = get_node("PhysicDude")
@onready var slime_animation2 = get_node("static/Slime4/slime/AnimationPlayer")
@onready var slime_animation3 = get_node("static/Slime5/slime/AnimationPlayer")
@onready var box_animation = get_node("static/StaticBox/AnimationPlayer")
@onready var slime2 = get_node("static/Slime4")
@onready var slime3 = get_node("static/Slime5")

func _ready() -> void:
	slime_animation2.play("appear_and_pulse")
	slime_animation3.play("appear_and_pulse")
	dude.hit.connect(_on_hit_static_box)
	dude.slime.connect(_on_hit_slime)
func _on_hit_static_box():
	box_animation.play("hit")
func _on_hit_slime(collider):
	var slime_parent_name = collider.get_parent().name

	if slime_parent_name == "Slime4" and slime2.dead != true:
		slime_animation2.play("dude_jump_on")
		slime2.dead = true
		dude.velocity.y = -400.0 / 2

	elif slime_parent_name == "Slime5" and slime3.dead != true:
		slime_animation3.play("dude_jump_on")
		slime3.dead = true
		dude.velocity.y = -400.0 / 2


	
	
	
	
	
	#slime_animation.play("appear_and_pulse")
	#slime_animation.animation_finished.connect(_on_appear_and_pulse_ended)
	#
#func _on_appear_and_pulse_ended(name):
	#if name == "appear_and_pulse":
		#slime_animation.play("boom")
