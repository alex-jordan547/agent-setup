---
name: wevehiculegen2-as-simulator
description: Use when testing or debugging AS announcements in wevehiculegen2 DM68 simulator, especially MP3/TTS, multilingual, loop, terminus, composition, or browser validation behavior.
---

# Wevehiculegen2 AS Simulator

## Overview
Use this for real manual validation of DM68 AS announcements in `wevehiculegen2`. The core rule: simulator behavior must be checked in the real app flow, not inferred only from unit tests, e2e scripts, or code reading.

## Non-Negotiables
- **Browser in-app is mandatory** for simulator validation. Use the Codex Browser/in-app browser on `http://localhost:8080/#/simulateur`; do not replace an explicit browser test with shell, curl, unit tests, or e2e scripts.
- Do not mix “manual browser test” and “e2e/unit test” evidence. They answer different questions.
- Before running a simulation, verify the composition really contains the target AS object, page, zone, and vehicle-state condition.
- Do not run lint in this project workflow. Use targeted tests or build checks only when useful.

## Fast Workflow
1. Open the simulator in Browser in-app: `http://localhost:8080/#/simulateur`.
2. Go to composition editing and add/select the page containing the exact AS object under test.
3. Check the activation condition: stop, next stop, exit from previous stop, detour, off-route, connection, departure, etc.
4. Import scenarios from `C:\Users\Alex Jordan\Documents\Developper\assets wesol\DM68` when scenario data is needed.
5. Prepare `core/bibmm` for MP3 cases. Fake `.mp3` files are valid if the test only needs file existence; filenames and paths must match the SAE data.
6. Run the simulation and record the exact AS output produced by the UI/runtime.

## Checklist
- Target object: `AS_ARRET`, `AS_PROCHAINARRET`, `AS_ARRETSIMPORTANTS`, `AS_CONNEXION`, `AS_DEPART`, `AS_DEV`, etc.
- State/position: especially terminus cases, where the useful position can be the segment before terminus or sortie d'arret, not “at terminus”.
- Language: test lang0 and at least one extra language for multilingual bugs.
- `ASFichierAudio`: test MP3 path and fallback TTS path.
- `IVVSceneMultilingueIgnoreeAS`: when true, extra languages should be silent for affected AS objects.
- Loop: verify the real pause source, commonly `TempsPauseAS` or `IVVPauseEntreCycleSequenceAS`.
- MP3 completeness: for combined announcements, missing one required file should normally force complete TTS fallback, not a partial MP3.

## Common Mistakes
- Launching the simulator before confirming the compo contains the target object.
- Testing the wrong vehicle state, especially terminus and sortie d'arret cases.
- Forgetting static audio files under `staticAudio/` while only creating variable stop files.
- Believing an e2e/unit result proves the browser simulation; it does not.
- Reusing a stale simulation state after an announcement has already played or loop timers have started.

## Evidence to Return
Report the object, state, language, audio mode, relevant files created/missing, scenario used, and exact AS text/file sequence observed in the Browser in-app.
