# Burial chamber presentation — 2026-11-05

Godot 4.7.2 Mobile renderer. Original geometry, existing credited materials.

## Implemented

Elliptical stone barrel vault and upper end walls close the formerly open sky;
four rib arches, tiered wall pilasters, six perimeter sarcophagi with raised
effigies and two rear pointed recesses articulate the chamber. Old rectangular
coffin placeholders removed. Six warm unshadowed torches and one cool central fill
support the existing lanterns; crypt-only ambient/fog/key-light values reduce the
outdoor appearance. Other regions reset these values on transition.

No new low world blockers: original floor, walls, entrance barrier and seal remain
authoritative. New architecture is cosmetic. The six tombs sit beyond x=8, keeping
the central arena clear. The high cosmetic vault has no physical collision, and
sarcophagi/pilasters are visual wall dressing. No boss timing, stats, reward, save
schema or interaction changes.

## Evidence

- Import: `.tools/burial-art-import.log`.
- **517 assertions PASS**, `.tools/burial-art-tests-final.log`. Includes actual
  boss attacks, barrier/reset/reward/seal/travel behavior and three unobstructed
  body-height combat corridors across the chamber.
- Native bounded capture exits 0: `.tools/burial-art-capture-final.log`. Vault,
  tomb and third-person HUD images inspected under `.tools/review/burial-*`.
  Review camera hides the knight only for architectural shots; third-person shot
  uses the actual player camera and HUD. No manual fight/camera playtest claimed.
- Separate Windows preview: `build/windows-burial-art`, `Play-Burial-Chamber.cmd`.
- Final build log: `.tools/burial-art-build-final.log`. Manifest payload hashes
  match; exported headless boot exits 0 with clean `.tools/burial-art-export.log`.
  This is not a manual exported gameplay acceptance pass.

## Limits

This is a chamber art increment, not finished character animation or audio. More
ornament, burial-specific materials and boss readability tuning remain. No FPS,
phone hardware or complete campaign acceptance claimed. Existing Android 0.5.1
link still has forest content; village/mausoleum/chamber require a later APK refresh.
Previous builds and saves retained.
