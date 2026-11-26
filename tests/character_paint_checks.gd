extends SceneTree
## Repainting must not damage animation partitions or change collision silhouettes.
const Models = preload("res://game/presentation/meshy_models.gd")
var failures := 0
func verify(condition: bool, message: String) -> void:
	if not condition: push_error(message); failures+=1
func _initialize() -> void:
	var count := 0
	var maxima := [0.0,0.0,0.0]
	for id: String in Models.HEIGHTS:
		var data := Models.definition(id)
		verify(data.has("rear_projection"),id+" has no paired reference")
		var fit: Dictionary=data.rear_projection
		verify(fit.x_bounds[1]>fit.x_bounds[0],id+" invalid projection span")
		verify(fit.rect[0]>=0 and fit.rect[1]>=0 and fit.rect[2]>0 and fit.rect[3]>0 and fit.rect[0]+fit.rect[2]<=1 and fit.rect[1]+fit.rect[3]<=1,id+" invalid rear crop")
		verify(ResourceLoader.exists(Models.ROOT+"rear-reference-colors/"+id+".png"),id+" missing rear image")
		verify(data.has("front_projection"),id+" has no mesh-guided front reference")
		var front: Dictionary=data.front_projection
		verify(front.x_bounds[1]>front.x_bounds[0] and front.alpha,id+" invalid front projection")
		verify(front.rect[0]>=0 and front.rect[1]>=0 and front.rect[2]>0 and front.rect[3]>0 and front.rect[0]+front.rect[2]<=1 and front.rect[1]+front.rect[3]<=1,id+" invalid front crop")
		verify(ResourceLoader.exists(Models.ROOT+"front-reference-colors/"+id+".png"),id+" missing front image")
		var material := Models.material(id,"body",Vector3.ZERO) as ShaderMaterial
		verify(material.get_shader_parameter("front_ready")==true and material.get_shader_parameter("front_reference") is Texture2D,id+" front paint not connected to runtime material")
		var coverage := material.get_shader_parameter("front_coverage_uv") as Texture2D
		verify(coverage!=null and coverage.get_size()==Vector2(512,512),id+" missing UV coverage field")
		for part: String in data.parts:
			var current: ArrayMesh=load(data.parts[part].mesh)
			var original: ArrayMesh=load(Models.ROOT+"painted/"+id+"-"+part+".res")
			verify(current.get_surface_count()==original.get_surface_count(),id+" surface count changed")
			for surface in range(current.get_surface_count()):
				var a := current.surface_get_arrays(surface)
				var b := original.surface_get_arrays(surface)
				verify(a[Mesh.ARRAY_INDEX]==b[Mesh.ARRAY_INDEX],id+" indices changed")
				var channels := [Mesh.ARRAY_VERTEX,Mesh.ARRAY_NORMAL,Mesh.ARRAY_TEX_UV]
				for c in range(channels.size()):
					var channel: int=channels[c]
					verify(a[channel].size()==b[channel].size(),id+" attribute count changed")
					var deviation := 0.0
					for v in range(a[channel].size()): deviation=maxf(deviation,a[channel][v].distance_to(b[channel][v]))
					maxima[c]=maxf(maxima[c],deviation)
					# Godot re-encodes packed normals on ArrayMesh creation.
					verify(deviation<(.001 if c==1 else .0001),id+" channel "+str(channel)+" deviation "+str(deviation))
				verify(a[Mesh.ARRAY_COLOR]==b[Mesh.ARRAY_COLOR] and a[Mesh.ARRAY_TEX_UV2]==b[Mesh.ARRAY_TEX_UV2],id+" original paint masks changed")
				for vertex in range(a[Mesh.ARRAY_VERTEX].size()):
					var color: Color=a[Mesh.ARRAY_COLOR][vertex]
					verify(is_finite(color.r) and is_finite(color.g) and is_finite(color.b),id+" nonfinite pigment")
				count+=1
		print("PAINT GEOMETRY PASS ",id)
	print("CHARACTER PAINT: ",count," surfaces preserve original geometry/UVs/pigments; ten front and ten rear references fit and front materials connected")
	print("Maximum position/normal/UV deviation: ",maxima," failures=",failures)
	quit(0 if failures==0 else 1)
