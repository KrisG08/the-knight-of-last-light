# Realistic asset candidate: native workload

Follow-up: a single-native-process repeat completed with p95 9.387 ms, worst
266.475 ms and peak working set 1.05 GiB; the 8.7-second hitch below did not repeat.
See acceptance-baseline-2026-11-04.md and data/acceptance-baseline-*.json for the
new measurement and limits. Direct visible app launch/new journey was also observed;
the earlier offscreen timeout remains historical, not proof of a launcher fix.

2026-11-04. Candidate: build/windows-realism/LastLight.exe.
PCK SHA256: 59F4B21E89CA3AE519ABB006EE84996DCD57C2329600B60D4D34C36DA35E148B.
EXE SHA256: D34D36F3BE1A6C49C56525AE86469B92E4F417DDF0B43CF00DD80C385C4B0562.

Godot 4.7.2 Mobile/Vulkan, RTX 3050 Ti Laptop, i5-12450H. Requested
1920x1080 window, logical 1280x720; actual render texture 2880x1620.
VSync and shadows enabled. Offscreen scripted exported workload, assisted HP;
not a human playthrough. Desktop power/background activity was uncontrolled.

Completed workload: exit 0 and completion marker, 69.57 seconds of route samples,
82.73 seconds including process startup. 7,117 wall interval samples: p50 8.346 ms,
p95 9.541 ms, p99 10.751 ms, worst **8,702.425 ms** in the refuge stage.
Village worst 77.655 ms; boss stage worst 25.921 ms. Peak process working set
1,108,070,400 bytes; engine video-memory monitor 655,102,736 bytes; peak draw
calls 872. Release static-memory monitor returned zero and is not meaningful.
Raw evidence: data/realism-slice.json and data/realism-process.json.

**Confound:** a second isolated native boot was mistakenly started during the
refuge stage. This is not a controlled single-instance performance result.
The large hitch must remain visible; its attribution to asset loading versus
concurrent GPU/process startup is unresolved. No stable FPS guarantee follows
from percentile values. A clean single-instance load/transition profile remains
necessary before performance acceptance.

An earlier attempt exited without a completed report and is inconclusive.
A concurrent 20-second standalone boot also timed out without an engine error.
An independent offscreen 120-frame boot follow-up also exceeded its 60-second
timeout, with an empty error log and only the Vulkan startup header. Its process
was stopped. This check is inconclusive; it must not be described as a successful
standalone boot. The exported benchmark did complete its actual route, but the
ordinary launcher still needs a visible user boot check and startup diagnosis.
Native source captures completed cleanly. Standalone follow-up evidence is kept
in .tools/realism-standalone-smoke-final/. Manifest hashes were independently
verified after export. All candidate testing uses isolated or memory-only saves.
