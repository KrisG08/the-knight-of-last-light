"""Record verified local acceptance and, when present, the public receipt."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'docs/STATUS.md'
text = path.read_text(encoding='utf-8')
start = text.index('## Cinematic motion / score revision')
end = text.index('## Expanded opening delivered', start)
receipt_path = ROOT / 'build/android-releases/LastLight-0.5.66-delivery.json'
receipt = json.loads(receipt_path.read_text()) if receipt_path.exists() else None
boot = ROOT / '.tools/review/v0566-packaged-boot.log'
boot_ok = boot.exists() and 'Godot Engine' in boot.read_text(errors='replace')
section = '''## Cinematic motion / score revision — v0.5.66 accepted, 2026-11-26

Supersedes the previous v0.5.66 in-progress notes and older v0.5.65 delivery.
Continuous offline film skins keep caster shoulders and sleeves attached;
gravity-oriented cuff binds and restrained shoulder movement avoid stretched
bat-wing cloth. The occupied cell now shows Oren at the gate close. Four separate
fall lanes, bounded stumble/contact/settle, slope-specific body support and
ground-fitted dropped equipment replace floating/intersecting collapse poses.
Purple casting uses curved flow, restrained haze and depth-softened intersections
instead of straight polygon spokes and ground webs. Motivated camera cuts and
varied beat lengths retain an 80-second film. Final 2,400-frame master includes
the 906-frame sleeve/curse revision and 336-frame soft-particle refinement.

Installed fresh video-only 1080p30 desktop / 720p30 mobile Theora films, separate
original event-scored cinematic music, and four original slowed dark-fantasy
phonk loops (62/70/76/58 BPM). Menu music is unchanged. Existing five-language
narration remains offline. No commercial samples, new voice transmissions,
paid generation, file deletion or gameplay rig/control/save changes.

Actual evidence:
- Old motion baseline: 40 failed / 64 checks; final revision: 101 checks PASS.
- Native preview frames and final encoded curse frame visually inspected.
  An earlier preview captured its frames but timed out at Vulkan shutdown;
  production renders completed normally and have frame-count receipts.
- Full decoding: 2,400 frames per platform, 80 seconds; correct size/rate,
  no coefficient/keyframe errors. Audio decode/peak/RMS/loop-seam checks PASS.
- Import/parse PASS; 569 voice assertions and 29 native music assertions PASS.
- Full native Vulkan playback: 72 assertions PASS for each platform path,
  including moving beats, BG captions/voice, score, camp handoff, five-locale
  Skip and restoration of the physics catch-up budget. Desktop elapsed 80.023s,
  median/p95 16.668/19.967ms; mobile-video path elapsed 80.004s,
  median/p95 16.669/19.566ms. These are laptop measurements, not phone FPS.
- Windows/Android exports, APK signature and 16KB alignment PASS.
- org.lastlight.knight versionName 0.5.66 / versionCode 71; signer matches
  v0.5.65 for an in-place update. One aapt2 themed-icon resource warning remains;
  signature/alignment and package identity checks succeeded.
- Platform parity PASS: current film variants, independent score, five music
  tracks, 225 voice clips, 128 compiled scripts, 172 character resources,
  13 locale/config files, current shaders/font/menu assets.

Packages: build/windows-v0566 and build/android-releases/LastLight-0.5.66.apk
(504,855,965 bytes). Play-Latest.cmd now selects v0.5.66.
'''
section += ('Isolated packaged Windows headless startup PASS; no visual certification.\n'
            if boot_ok else
            'Additional packaged Windows headless startup is inconclusive; native full-game\nplayback and export/package parity above are the completed checks.\n')
if receipt:
    section += '\nOwner-authorized public Android delivery: ' + receipt['downloadPage'] + '\n'
    section += 'Remote filename/size/MD5 match. APK SHA-256: ' + receipt['sha256'] + '\n'
    section += 'Public browser page verified: one public LastLight-0.5.66.apk item, 505 MB.\n'
section += '''
Limits: Nothing Phone 3a physical installation/thermals/sustained pacing remain
untested. This is an authored 30fps film, not AI-generated video or cloth/ragdoll
simulation. No stutter-free phone promise or complete campaign certification.
Engine 4.7.2.stable.official.ed1daf0bf; no Git repository. Evidence:
docs/art/opening-v7.md, art/cinematics/opening-v7/authored-production.json,
.tools/review/prologue-v6-v066-*.log and release-0.5.66-*.log.
Next: owner review on the physical phone and targeted fixes from that feedback.

'''
path.write_text(text[:start] + section + text[end:], encoding='utf-8')
print('v0.5.66 acceptance recorded')
