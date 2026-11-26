extends SceneTree
## Static interchange copies only. Never edits game meshes/materials or saves.
const Art = preload("res://game/presentation/art_kit.gd")
const Meshy = preload("res://game/presentation/meshy_models.gd")
const Textures = ["albedo_texture","base_texture","reference_color","scale_texture"]
var destination: String
var entries: Array = []
var mesh_cache: Dictionary = {}
var material_cache: Dictionary = {}
var texture_cache: Dictionary = {}
var images: Dictionary = {}
var failures := 0
var world_export := false
class PoseActor extends CharacterBody3D:
	var health := 100.0
	var state := "idle"

func _initialize() -> void: call_deferred("run")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	destination = args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://art_exports/Last-Light-Model-Pack-2026-11-24")
	DirAccess.make_dir_recursive_absolute(destination)
	if "--probe-import" in args:
		var scene: PackedScene=load("res://assets/vendor/hostile_sources/strong-knight.glb")
		var source: Node3D=scene.instantiate(); root.add_child(source)
		await export_visual(source,"02-GLB/imported/strong-knight","static original imported geometry; custom channels and rig removed")
		source.free(); quit(0 if failures==0 else 1); return
	if "--worlds-only" in args:
		entries=JSON.parse_string(FileAccess.get_file_as_string(destination+"/models-partial.json"))
		await export_worlds()
		finish(); return
	if "--probe-soldier" in args:
		var actor := PoseActor.new(); actor.process_mode=Node.PROCESS_MODE_DISABLED; root.add_child(actor)
		var visual := Node3D.new(); actor.add_child(visual)
		var pivot := Node3D.new(); pivot.position.y=1; visual.add_child(pivot)
		print("PROBE building soldier")
		preload("res://game/presentation/hostile_models.gd").build("soldier",actor,visual,pivot,Art.material("pack_accent",Color("a780cc")))
		print("PROBE built soldier")
		await export_visual(visual,"02-GLB/villains/soldier","probe")
		actor.free(); quit(0 if failures==0 else 1); return
	for id in ["knight","oren","lyra","cael","goblin","gravedigger","thorn-beast","fallen-commander","iron-warden","maldrek"]:
		var source := Node3D.new(); root.add_child(source)
		var weapon := Node3D.new(); source.add_child(weapon)
		Meshy.build(source,id,weapon)
		await export_visual(source,"02-GLB/characters/meshy-"+id,"assembled current Meshy geometry; static material approximation")
		source.free()
	var hero := Node3D.new(); root.add_child(hero)
	var hero_weapon := Node3D.new(); hero.add_child(hero_weapon)
	preload("res://game/presentation/scanned_knight.gd").build(hero,hero_weapon)
	await export_visual(hero,"02-GLB/characters/player-knight","current scanned player equipment in rest pose")
	hero.free()
	for id in ["soldier","villager","hound","shade","gravedigger","thorn","commander","warden","maldrek"]:
		var actor := PoseActor.new(); actor.process_mode=Node.PROCESS_MODE_DISABLED; root.add_child(actor)
		var visual := Node3D.new(); actor.add_child(visual)
		var pivot := Node3D.new(); pivot.position.y=1; visual.add_child(pivot)
		preload("res://game/presentation/hostile_models.gd").build(id,actor,visual,pivot,Art.material("pack_accent",Color("a780cc")))
		await export_visual(visual,"02-GLB/villains/"+id,"current villain with authored equipment; static rest pose")
		actor.free()
	for id in ["goblin","troll","dwarf","wraith","sentinel","gargoyle","barghest","ash_dragon"]:
		var creature = preload("res://game/presentation/ambient_creature.gd").new()
		creature.setup(id,1.0); root.add_child(creature); creature.set_process(false)
		await export_visual(creature,"02-GLB/creatures/"+id,"passive creature; movement remains in Godot runtime")
		creature.free()
	for kind in ["scout_satchel","family_locket","memorial","reliquary"]:
		var prop := Node3D.new(); root.add_child(prop)
		preload("res://game/presentation/quest_props.gd").attach(prop,kind)
		await export_visual(prop,"02-GLB/props/"+kind,"current detailed quest prop")
		prop.free()
	for kind in ["lantern","gothic_arch","village_house","sword"]:
		var prop := Node3D.new(); root.add_child(prop)
		match kind:
			"lantern": Art.lantern(prop,Vector3.ZERO)
			"gothic_arch": Art.pointed_arch(prop,Vector3.ZERO,6,8)
			"village_house": preload("res://game/presentation/village_kit.gd").house(prop,Vector3(8,7,9),1)
			"sword": preload("res://game/presentation/hostile_models.gd").blade(prop,1.35,Art.material("pack_sword",Color("7c858b"),.45))
		await export_visual(prop,"02-GLB/props/"+kind,"authored geometry from shared game builders")
		prop.free()
	var source_paths: Array[String] = []
	find_sources("res://assets/vendor",source_paths)
	for path in source_paths:
		var scene = load(path)
		if not scene is PackedScene: continue
		var source: Node3D = scene.instantiate(); root.add_child(source)
		await export_visual(source,"02-GLB/imported/"+path.get_file().get_basename(),"source imported model: "+path)
		source.free()
	await export_worlds()
	finish()

func export_worlds() -> void:
	for id in ["refuge","village","blackwood","order","peaks","citadel","crypt","grove","sanctum","forge","ritual"]:
		var region = preload("res://game/world/regions/graybox_region.gd").new()
		region.process_mode=Node.PROCESS_MODE_DISABLED; root.add_child(region)
		region.build("region."+id)
		await export_visual(region,"03-Worlds/"+id,"static world geometry including code-authored buildings, props, instanced nature and portals; no gameplay, sky or animated shaders")
		region.free()

func finish() -> void:
	FileAccess.open(destination+"/models.json",FileAccess.WRITE).store_string(JSON.stringify({"date":"2026-11-24","game_version":ProjectSettings.get_setting("application/config/version"),"models":entries,"failures":failures},"  "))
	print("MODEL PACK: ",entries.size()," validated GLB files; failures=",failures)
	quit(0 if failures==0 else 1)

func find_sources(folder: String, result: Array[String]) -> void:
	for filename in DirAccess.get_files_at(folder):
		if filename.get_extension().to_lower() in ["glb","gltf"]: result.append(folder+"/"+filename)
	for subfolder in DirAccess.get_directories_at(folder): find_sources(folder+"/"+subfolder,result)

func export_visual(source: Node3D, relative: String, note: String) -> void:
	await process_frame
	print("EXPORT BEGIN ",relative)
	mesh_cache.clear()
	material_cache.clear()
	world_export=relative.begins_with("03-Worlds/")
	var visual := Node3D.new(); visual.name=relative.get_file().replace("-","_")
	copy_visuals(source,visual,source.global_transform.affine_inverse())
	print("EXPORT COPIED ",relative)
	var count := visual.get_child_count()
	if count==0: push_error("Empty export: "+relative); failures+=1; visual.free(); return
	var path := destination+"/"+relative+".glb"
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var document := GLTFDocument.new(); var state := GLTFState.new()
	print("EXPORT SERIALIZE ",relative)
	var appended := document.append_from_scene(visual,state)
	print("EXPORT APPENDED ",relative)
	if appended!=OK or document.write_to_filesystem(state,path)!=OK:
		push_error("Export failed: "+relative); failures+=1; visual.free(); return
	print("EXPORT WRITTEN ",relative)
	visual.free()
	print("EXPORT FREED ",relative)
	if world_export:
		entries.append({"file":relative+".glb","mesh_instances":count,"bytes":FileAccess.get_file_as_bytes(path).size(),"note":note+"; structural GLB validation by packager"})
		print("GLB WRITTEN ",relative," instances=",count)
		return
	var restored_state := GLTFState.new()
	if document.append_from_file(path,restored_state)!=OK:
		push_error("GLB cannot be read back: "+relative); failures+=1; return
	var restored := document.generate_scene(restored_state)
	if restored==null or restored.find_children("*","MeshInstance3D",true,false).is_empty():
		push_error("GLB geometry missing: "+relative); failures+=1
		if restored!=null: restored.free()
		return
	if restored!=null: restored.free()
	entries.append({"file":relative+".glb","mesh_instances":count,"bytes":FileAccess.get_file_as_bytes(path).size(),"note":note})
	print("GLB PASS ",relative," instances=",count)

func copy_visuals(node: Node, target: Node3D, inverse: Transform3D) -> void:
	if node is Node3D and not node.visible: return
	if node is MeshInstance3D and node.mesh!=null:
		var instance := MeshInstance3D.new(); instance.name="Part_%05d"%target.get_child_count()
		instance.mesh=portable_mesh(node.mesh,node.material_override)
		instance.transform=inverse*node.global_transform
		target.add_child(instance)
	elif node is MultiMeshInstance3D and node.multimesh!=null and node.multimesh.mesh!=null:
		var multi: MultiMesh=node.multimesh
		var mesh := portable_mesh(multi.mesh,node.material_override)
		var count := multi.instance_count if multi.visible_instance_count<0 else mini(multi.instance_count,multi.visible_instance_count)
		for index in range(count):
			var instance := MeshInstance3D.new(); instance.name="Instance_%05d"%target.get_child_count()
			instance.mesh=mesh; instance.transform=inverse*node.global_transform*multi.get_instance_transform(index)
			target.add_child(instance)
	for child in node.get_children(): copy_visuals(child,target,inverse)

func portable_mesh(mesh: Mesh, override: Material) -> ArrayMesh:
	var cache_key := str(mesh.get_instance_id())+"/"+str(override.get_instance_id() if override!=null else 0)
	if mesh_cache.has(cache_key): return mesh_cache[cache_key]
	var result := ArrayMesh.new()
	for surface in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface)
		var material: Material=override if override!=null else mesh.surface_get_material(surface)
		var converted := portable_material(material)
		if material is ShaderMaterial and material.shader!=null and material.shader.resource_path.ends_with("meshy_surface.gdshader"):
			bake_meshy(arrays,material)
			converted.vertex_color_use_as_albedo=true; converted.albedo_texture=null; converted.albedo_color=Color.WHITE
		arrays[Mesh.ARRAY_BONES]=null; arrays[Mesh.ARRAY_WEIGHTS]=null
		for channel in range(Mesh.ARRAY_CUSTOM0,Mesh.ARRAY_CUSTOM3+1): arrays[channel]=null
		result.add_surface_from_arrays(mesh.surface_get_primitive_type(surface) if mesh is ArrayMesh else Mesh.PRIMITIVE_TRIANGLES,arrays)
		result.surface_set_material(surface,converted)
	mesh_cache[cache_key]=result
	return result

func portable_material(material: Material) -> StandardMaterial3D:
	var key := material.get_instance_id() if material!=null else 0
	if material_cache.has(key): return material_cache[key]
	var result := make_material(material)
	material_cache[key]=result
	return result

func make_material(material: Material) -> StandardMaterial3D:
	if material is StandardMaterial3D:
		if world_export:
			var simple := StandardMaterial3D.new()
			simple.albedo_color=material.albedo_color
			simple.roughness=material.roughness; simple.metallic=material.metallic
			simple.vertex_color_use_as_albedo=material.vertex_color_use_as_albedo
			return simple
		var copy := material.duplicate() as StandardMaterial3D
		# Portable preview copies keep color and authored scalar PBR.
		# Avoid expensive per-material repacking of separate ORM channels.
		copy.metallic_texture=null; copy.roughness_texture=null
		copy.ao_texture=null; copy.ao_enabled=false
		copy.normal_enabled=false; copy.normal_texture=null
		copy.albedo_texture=portable_texture(copy.albedo_texture)
		return copy
	var result := StandardMaterial3D.new(); result.roughness=.8
	if not material is ShaderMaterial: result.albedo_color=Color("777582"); return result
	var parameters := {}
	for uniform in material.shader.get_shader_uniform_list(): parameters[uniform.name]=material.get_shader_parameter(uniform.name)
	for key in ["cloth_color","source_tint","base_color","albedo","tint","color"]:
		if parameters.get(key) is Color: result.albedo_color=parameters[key]; break
	if not world_export:
		for key in Textures:
			if parameters.get(key) is Texture2D: result.albedo_texture=parameters[key]; break
	if result.albedo_texture==null and result.albedo_color==Color.WHITE: result.albedo_color=Color("604777")
	result.cull_mode=BaseMaterial3D.CULL_DISABLED
	result.albedo_texture=portable_texture(result.albedo_texture)
	return result

func portable_texture(texture: Texture2D) -> Texture2D:
	if texture==null: return null
	var key := texture.get_instance_id()
	if texture_cache.has(key): return texture_cache[key]
	var picture := texture.get_image()
	if picture==null: return null
	if picture.is_compressed(): picture.decompress()
	if maxi(picture.get_width(),picture.get_height())>1024:
		var scale := 1024.0/maxi(picture.get_width(),picture.get_height())
		picture.resize(maxi(1,roundi(picture.get_width()*scale)),maxi(1,roundi(picture.get_height()*scale)),Image.INTERPOLATE_LANCZOS)
	var result := ImageTexture.create_from_image(picture)
	texture_cache[key]=result
	return result

func bake_meshy(arrays: Array, material: ShaderMaterial) -> void:
	var texture: Texture2D=material.get_shader_parameter("reference_color")
	if texture==null: return
	var image_key := texture.get_instance_id()
	if not images.has(image_key):
		var picture := texture.get_image()
		if picture.is_compressed(): picture.decompress()
		images[image_key]=picture
	var picture: Image=images[image_key]
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var colors: PackedColorArray=arrays[Mesh.ARRAY_COLOR]
	var uv: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV]
	var masks: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV2]
	var tint = material.get_shader_parameter("variant_tint")
	if not tint is Color: tint=Color.WHITE
	var baked := PackedColorArray()
	for index in range(vertices.size()):
		var base: Color=colors[index] if colors.size()>index else Color("666373")
		var coordinate: Vector2=uv[index] if uv.size()>index else Vector2.ZERO
		var reference := picture.get_pixel(clampi(roundi(coordinate.x*(picture.get_width()-1)),0,picture.get_width()-1),clampi(roundi(coordinate.y*(picture.get_height()-1)),0,picture.get_height()-1)).srgb_to_linear()
		var confidence := floorf(masks[index].y/32.0)/31.0 if masks.size()>index else 0.0
		var luma := reference.r*.299+reference.g*.587+reference.b*.114
		var chroma := maxf(reference.r,maxf(reference.g,reference.b))-minf(reference.r,minf(reference.g,reference.b))
		var background := smoothstep(.28,.52,luma)*(1-smoothstep(.025,.09,chroma))
		var color: Color=(base*1.055).lerp(reference,confidence*(1-background)*.92)*tint
		color.a=1; baked.append(color)
	arrays[Mesh.ARRAY_COLOR]=baked
	arrays[Mesh.ARRAY_TEX_UV2]=null
