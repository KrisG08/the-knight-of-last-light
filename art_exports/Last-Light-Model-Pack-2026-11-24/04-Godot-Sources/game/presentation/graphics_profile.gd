extends RefCounted
## Platform rendering policy; never changes combat, display mode or save progress.
const QUALITIES=["high","balanced","performance"]
static func resolve(quality: String, mobile: bool, pixels: Vector2i, resolution: String="profile", target_fps: int=60) -> Dictionary:
	if quality not in QUALITIES: quality="high"
	var profile: Dictionary
	if mobile:
		# Phone (3a) starting profiles. Sustained performance needs device review.
		profile={
			"high":{"scale":1.0,"pixel_budget":2600000,"msaa":Viewport.MSAA_4X,"anisotropy":Viewport.ANISOTROPY_16X,"lod":0.8,"shadows":true,"atlas":2048,"shadow_distance":48.0},
			"balanced":{"scale":0.80,"pixel_budget":1650000,"msaa":Viewport.MSAA_2X,"anisotropy":Viewport.ANISOTROPY_8X,"lod":1.5,"shadows":true,"atlas":1024,"shadow_distance":16.0},
			"performance":{"scale":0.65,"pixel_budget":1100000,"msaa":Viewport.MSAA_2X,"anisotropy":Viewport.ANISOTROPY_4X,"lod":2.5,"shadows":false,"atlas":1024,"shadow_distance":12.0}
		}[quality].duplicate()
	else:
		profile={
			"high":{"scale":1.0,"pixel_budget":4665600,"msaa":Viewport.MSAA_4X,"anisotropy":Viewport.ANISOTROPY_16X,"lod":0.8,"shadows":true,"atlas":4096,"shadow_distance":100.0},
			"balanced":{"scale":0.90,"pixel_budget":3000000,"msaa":Viewport.MSAA_4X,"anisotropy":Viewport.ANISOTROPY_8X,"lod":1.2,"shadows":true,"atlas":2048,"shadow_distance":65.0},
			"performance":{"scale":0.80,"pixel_budget":2073600,"msaa":Viewport.MSAA_2X,"anisotropy":Viewport.ANISOTROPY_4X,"lod":2.0,"shadows":false,"atlas":2048,"shadow_distance":35.0}
		}[quality].duplicate()
	if resolution not in ["profile","native"]: resolution="profile"
	if resolution=="native":
		profile.scale=1.0
		# Fits Phone (3a)'s full 2392x1080 buffer, while bounding oversized surfaces.
		profile.pixel_budget=2600000 if mobile else 8294400
	elif mobile and target_fps>60:
		# Explicit profile mode trades pixel load for the shorter frame budget.
		# This changes only on settings/resize events, not on every frame.
		var ratio:=60.0/clampi(target_fps,60,120)
		profile.scale*=sqrt(ratio)
		profile.pixel_budget=roundi(profile.pixel_budget*ratio)
	var area:=float(maxi(1,pixels.x))*float(maxi(1,pixels.y))
	profile.scale=minf(profile.scale,sqrt(float(profile.pixel_budget)/area))
	profile.scale=clampf(profile.scale,0.25,1.0)
	profile.quality=quality; profile.mobile=mobile; profile.resolution=resolution
	profile.target_fps=target_fps
	return profile

static func apply(viewport: Viewport, sun: DirectionalLight3D, profile: Dictionary, previous: Dictionary) -> void:
	# Only settings/resize events change buffers; no per-frame resolution churn.
	if not is_equal_approx(viewport.scaling_3d_scale,profile.scale): viewport.scaling_3d_scale=profile.scale
	if viewport.msaa_3d!=profile.msaa: viewport.msaa_3d=profile.msaa
	viewport.scaling_3d_mode=Viewport.SCALING_3D_MODE_BILINEAR
	viewport.anisotropic_filtering_level=profile.anisotropy
	viewport.mesh_lod_threshold=profile.lod
	if previous.get("atlas",0)!=profile.atlas or previous.get("mobile")!=profile.mobile:
		RenderingServer.directional_shadow_atlas_set_size(profile.atlas,profile.mobile)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW if profile.mobile or profile.quality!="high" else RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	sun.shadow_enabled=profile.shadows
	sun.directional_shadow_max_distance=profile.shadow_distance
	sun.directional_shadow_mode=DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS if profile.mobile or profile.quality!="high" else DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_blend_splits=not profile.mobile and profile.quality=="high"
	sun.directional_shadow_fade_start=0.75
