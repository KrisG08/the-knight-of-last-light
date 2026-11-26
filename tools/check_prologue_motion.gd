extends "res://tools/render_prologue_v6.gd"
const Probe=preload("res://tools/film_mesh_probe.gd")
var failures:=0
var assertions:=0
func check(ok: bool,message: String) -> void:
	assertions+=1
	if not ok: failures+=1; print("MOTION_FAIL ",message)
func preview() -> void:
	for second in [12.0,15.0,44.0,47.0]:
		update_film(second)
		var data: Dictionary=preload("res://game/presentation/meshy_models.gd").definition("maldrek")
		for part in ["left_arm","right_arm"]:
			var origin: Array=data.parts[part].origin
			var attachment: Vector3=wizard_rig.body.to_global(Vector3(origin[0],origin[1],origin[2]))
			check(wizard_rig[part].global_position.distance_to(attachment)<.015,"Wizard shoulder follows torso: "+part+" at "+str(second))
	update_film(27.0)
	var captive: MeshInstance3D=village.oren.find_children("*","MeshInstance3D",true,false)[0]
	check(captive.is_visible_in_tree(),"Prisoner is visible")
	check(Vector2(captive.global_position.x,captive.global_position.z).distance_to(Vector2(village.points.oren.x,village.points.oren.z))<1.0,"Prisoner remains inside the cell when he turns")
	for second in [52.0,54.0,56.0,58.0,59.0,60.5,62.0,65.0,68.0]:
		update_film(second)
		var boxes: Array[AABB]=[]
		for item in knights:
			var actor: Node3D=item.node
			if not actor.visible: continue
			var points:=Probe.vertices(actor,7)
			var penetration:=0.0
			for point in points: penetration=maxf(penetration,forest.height_at(point.x,point.z)-point.y)
			check(penetration<.035,"Knight does not enter terrain at "+str(second)+"; depth="+str(penetration))
			var box:=Probe.bounds(points)
			for previous in boxes:
				var overlap:=box.intersection(previous)
				check(overlap.size.x<.08 or overlap.size.z<.08,"Falling knights occupy separate spaces at "+str(second))
			boxes.append(box)
	print("Cinematic motion: ",assertions," checks; ","PASS" if failures==0 else "FAIL", "; failures=",failures)
	quit(0 if failures==0 else 1)
