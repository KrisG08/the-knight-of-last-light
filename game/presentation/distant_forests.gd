extends RefCounted
## Instanced, noninteractive pine belts outside the authored play area.
static var prototypes: Dictionary = {}

static func prepare() -> void:
	if not prototypes.is_empty(): return
	for variant in ["a","b","c"]:
		var mesh := QuadMesh.new(); mesh.size=Vector2(0.707,1.06); mesh.center_offset=Vector3(0,0.53,0)
		var material := StandardMaterial3D.new()
		material.albedo_texture=load("res://assets/forest/pine_sapling_small_"+variant+".png")
		material.albedo_color=Color("829985"); material.roughness=1.0
		material.billboard_mode=BaseMaterial3D.BILLBOARD_FIXED_Y
		material.billboard_keep_scale=true; material.cull_mode=BaseMaterial3D.CULL_DISABLED
		material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.alpha_scissor_threshold=0.15
		material.alpha_antialiasing_mode=BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
		material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		mesh.material=material
		for quality in ["near","far"]: prototypes["pine_sapling_small_"+variant+"/"+quality]=mesh

static func build(root: Node3D, sample_surface: Callable, frame: Transform3D) -> void:
	prepare()
	var forest := Node3D.new(); forest.name="HillsideForest"; root.add_child(forest)
	var random := RandomNumberGenerator.new(); random.seed=91517
	var groups := {}
	var count := 0
	for band in ["near","far"]:
		for index in range(2400 if band=="near" else 14000):
			var angle := random.randf()*TAU
			var distance := random.randf_range(40,220) if band=="near" else random.randf_range(220,950)
			var at: Vector3 = sample_surface.call(angle,distance)
			var right: Vector3 = sample_surface.call(angle+0.002,distance)-at
			var outward: Vector3 = sample_surface.call(angle,distance+1.0)-at
			var normal := (frame.basis*outward).cross(frame.basis*right).normalized()
			if absf(normal.y)<0.58: continue
			# Preserve openings in the canopy instead of forming an even tree grid.
			if sin(angle*7+distance*0.023)>0.84: continue
			var key: String = "pine_sapling_small_"+["a","b","c"][index%3]+"/"+band
			var group: String = key+"/"+str(int(angle/TAU*4))
			if not groups.has(group): groups[group]={"mesh":key,"transforms":[]}
			var height := random.randf_range(8,16) if band=="near" else random.randf_range(13,24)
			var basis := frame.basis.inverse()*Basis(Vector3.UP,random.randf()*TAU).scaled(Vector3.ONE*height)
			groups[group].transforms.append(Transform3D(basis,at))
			count += 1
	for group in groups.values():
		var batch := MultiMesh.new(); batch.transform_format=MultiMesh.TRANSFORM_3D
		batch.mesh=prototypes[group.mesh]; batch.instance_count=group.transforms.size()
		for index in range(batch.instance_count): batch.set_instance_transform(index,group.transforms[index])
		var node := MultiMeshInstance3D.new(); node.multimesh=batch
		node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.visibility_range_end=1500; forest.add_child(node)
	forest.set_meta("pine_count",count)
