extends SceneTree
const Models = preload("res://game/presentation/meshy_models.gd")
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for id in Models.HEIGHTS:
		var root_model := Node3D.new(); root.add_child(root_model)
		var rig := Models.build(root_model,id)
		assert(root_model.find_children("*","CollisionShape3D",true,false).is_empty())
		assert(rig.legs.size()==(4 if id=="thorn-beast" else 2))
		var bounds := AABB(); var first := true; var count := 0
		var pigments := {}; var lowest := 10.0; var highest := 0.0
		for node in root_model.find_children("*","MeshInstance3D",true,false):
			var box: AABB = node.global_transform*node.mesh.get_aabb()
			bounds = box if first else bounds.merge(box); first = false
			for surface in range(node.mesh.get_surface_count()):
				var material: ShaderMaterial = node.mesh.surface_get_material(surface)
				var texture: Texture2D = material.get_shader_parameter("reference_color")
				assert(texture != null and texture.get_width()>=1024)
				var arrays: Array = node.mesh.surface_get_arrays(surface)
				assert(arrays[Mesh.ARRAY_VERTEX].size()==arrays[Mesh.ARRAY_NORMAL].size())
				assert(arrays[Mesh.ARRAY_COLOR].size()==arrays[Mesh.ARRAY_VERTEX].size())
				assert(arrays[Mesh.ARRAY_TEX_UV2].size()==arrays[Mesh.ARRAY_VERTEX].size())
				for normal: Vector3 in arrays[Mesh.ARRAY_NORMAL]: assert(normal.is_finite() and absf(normal.length()-1.0)<0.02)
				for mask: Vector2 in arrays[Mesh.ARRAY_TEX_UV2]: assert(mask.x>=0 and mask.x<=1 and mask.y>=0 and mask.y<=1023)
				for color: Color in arrays[Mesh.ARRAY_COLOR]:
					pigments[color.to_html(false)] = true
					lowest = minf(lowest,color.get_luminance()); highest = maxf(highest,color.get_luminance())
				for index in arrays[Mesh.ARRAY_INDEX]: assert(index>=0 and index<arrays[Mesh.ARRAY_VERTEX].size())
				count += arrays[Mesh.ARRAY_INDEX].size()/3
		assert(absf(bounds.position.y)<0.01 and absf(bounds.size.y-Models.HEIGHTS[id])<0.02)
		assert(count<=75000)
		assert(pigments.size()>8 and highest-lowest>0.04)
		var leg: Node3D = rig.legs[0]
		var before: Transform3D = leg.get_child(0).global_transform
		leg.rotation.x = 0.35
		assert(not before.is_equal_approx(leg.get_child(0).global_transform))
		print("PASS ",id," floor/height/geometry/budget/limb movement: ",count)
		root_model.free()
	quit()
