# ADR 0018: Explicit platform rendering profiles

Status: implemented, 2026-11-08.

Owner revision v0.5.51, 2026-11-17: Mobile High now starts at 100% up to
2.6 MP, 4x MSAA, 16x anisotropic filtering, desktop High mesh threshold 0.8,
and 48 m directional shadows in a 2048 atlas. Preserve the existing 60 FPS
default and explicit 90/120 profile-resolution tradeoff. Native screen remains
available. Balanced/Performance and persisted choices retain their behavior.
The APK already declares isGame=true and appCategory=0. Nothing's documented
Game Mode can require manually adding sideloaded games in Special features.
No vendor-specific Game Mode API or guaranteed mobile frame rate is implied.

Owner requests the best practical visual quality and smoothness on Nothing Phone
(3a) and the inspected i5-12450H/RTX 3050 Ti Laptop 4 GiB/15.7 GiB RAM machine.
Keep the shared Godot Mobile renderer and shared authored assets. Rendering
preferences remain local settings, outside campaign state and cloud journeys.

`graphics_profile.gd` resolves High/Balanced/Performance into a bounded pixel
budget, MSAA, anisotropic filtering, mesh LOD and directional shadow settings.
Desktop High preserves the existing maximum 2880x1620 raster budget observed
under Windows DPI scaling, adds 16x texture filtering, more retained geometry
and blended soft shadow cascades. Mobile High increases the former 65% 3D scale
to 90% at 2392x1080, adds short-range shadows, keeps 2x MSAA and uses 8x filtering.
The screen/UI resolution does not change. Large/HiDPI buffers respect the
profile pixel budget. Standard alpha-to-coverage improves pine needle edges.

The default pacing cap is 60; v0.5.38 offers 30/60/90/120 on both platforms,
removing the mobile-only 60 clamp. VSync remains on normally. Frame limits are ceilings, not sustained
performance promises. Owner can select a lighter mode and optional FPS counter.
Keep display size/mode untouched when changing graphics or travelling.

Do not oscillate resolution every frame: changing render buffers can cause
allocation/shader hitches and produces visible clarity changes. No automatic
quality changes during combat. Keep legacy Low graphics migration and validate
all persisted settings. No renderer switch, Forward+-only effects or unsupported
FSR claims. This does not change the quality ceiling of the source artwork.

Owner revision v0.5.38: separate profile resolution from explicit native-screen
resolution. Native supports the Phone (3a)'s actual full 2392x1080 buffer, capped
at 2.6 MP on mobile / 8.2944 MP desktop for oversized surfaces. Profile mode at
90/120 targets lowers mobile pixel work by 60/target. Native preserves detail
independently of the selected ceiling. Neither changes physics tick rate or
generates synthetic frames. Persist choices, display resulting buffer dimensions,
and keep the default 60/Profile preferences. No 160-FPS/2160p phone claim: the
panel is up to 120 Hz/1080x2392. Android built-in frame pacing remains enabled.

Phone specifications: https://checkout-eu.nothing.tech/pages/phone-3a
Godot scaling and supported renderers:
https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html
Godot rendering API:
https://docs.godotengine.org/en/stable/classes/class_viewport.html
https://docs.godotengine.org/en/stable/classes/class_renderingserver.html

Verification: persistence/migration, pixel budgets, real UI controls, untouched
window/progress, native five-language settings views, and native timing before/
after on identical fixture routes. Physical Phone (3a) thermal/FPS acceptance
remains required; laptop or touch emulation cannot establish mobile performance.
