extends Node

# Presentation only. Combat clocks, hit sweeps and the collision capsule stay owned
# by the existing actor. This node never moves the CharacterBody3D or weapon pivot.
var actor: CharacterBody3D
var rig: Dictionary
var clock: float = 0

func setup(owner_actor: CharacterBody3D, model: Dictionary) -> void:
	actor = owner_actor
	rig = model

func _process(delta: float) -> void:
	if not is_instance_valid(actor):
		return
	clock += delta
	var alive: bool = actor.health>0
	var moving: float = minf(1,Vector2(actor.velocity.x,actor.velocity.z).length()/2.0) if alive else 0.0
	var active: bool = actor.state in ["windup","strike"] and alive
	preload("res://game/presentation/hostile_grip.gd").update(rig,alive,active,delta)
	var phase: float = clock*6.0
	var legs: Array = rig.get("legs",[])
	for index in range(legs.size()):
		var offset: float = [0,PI,PI,0][index] if legs.size()==4 else index*PI
		var target: float = sin(phase+offset)*0.32*moving if not active else 0.0
		legs[index].rotation.x = lerpf(legs[index].rotation.x,target,minf(1,delta*12))
	if is_instance_valid(rig.get("body")):
		rig.body.position.y = sin(clock*2.0)*0.012 if alive else 0.0
	if is_instance_valid(rig.get("jaw")):
		rig.jaw.rotation.x = 0.22+sin(clock*7)*0.04 if active else 0.02
	if is_instance_valid(rig.get("tail")):
		rig.tail.rotation.y = sin(clock*2)*0.12 if alive else 0.0
	if is_instance_valid(rig.get("warning")):
		rig.warning.visible = actor.state=="windup" and alive
