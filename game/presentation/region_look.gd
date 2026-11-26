extends RefCounted
## Owner-approved violet-night palette. Restored-world lighting remains separate.
const INDOORS = ["region.crypt","region.sanctum","region.forge","region.ritual"]
static func apply(environment: Environment, sun: DirectionalLight3D, id: String, completed: bool) -> void:
	var sky := environment.sky.sky_material as ShaderMaterial
	sky.set_shader_parameter("violet_night",0.0 if completed else 1.0)
	if completed: return
	var indoor := id in INDOORS
	environment.fog_light_color = Color("21152e") if indoor else Color("241530")
	environment.ambient_light_color = Color("a28abb")
	environment.ambient_light_energy = 0.29 if indoor else 0.39
	environment.fog_density = 0.0035 if indoor else 0.003
	sun.light_color = Color("b99ad9")
	sun.light_energy = 0.08 if indoor else 0.58
	if id == "region.village": environment.ambient_light_energy = 0.35
	if id in ["region.blackwood","region.grove"]:
		environment.ambient_light_color = Color("9585aa")
		environment.ambient_light_energy = 0.41
	if id == "region.peaks": sun.light_energy = 0.65
	if id == "region.citadel": sun.light_energy = 0.52
	if id == "region.forge": environment.ambient_light_color = Color("ac8ba7")
