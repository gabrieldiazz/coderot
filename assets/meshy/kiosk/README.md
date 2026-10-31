# Abandoned information kiosk

Purpose: one distinctive retro prop for the CODE ROT plaza. Generation is an
optional presentation asset; match gameplay never depends on this mesh.

The manifest records the exact prompts, task IDs, settings and balance snapshots.
Credentials and temporary signed download URLs are never saved in the manifest.
Both downloaded meshes contain 3,601 triangles (checked from GLB indices).
Generation cost: preview 20 + texture 10 = 30 credits. Balance: 1,100 → 1,070.
Both stages completed successfully and their thumbnails were visually inspected.
Studio import and in-game rendering are still pending.

## Import and placement

1. Download and extract `assets/meshy/kiosk-import.zip` on your PC.
2. In Roblox Studio's Importer, select `refine.gltf` (keep `refine.bin` beside it).
   FBX plus the standalone base-color texture are included as an alternative. Inspect the mesh, textures, and
   orientation. Upload under the experience owner/group so the place can use it.
3. In Edit mode create a folder named `CodeRotAssets` in `ServerStorage`.
4. Put the imported **Model** inside it and name it `InformationKiosk`.
   The model should be upright, with its front facing local negative Z.
5. Start a fresh Play test. The lobby builder clones it, anchors it, disables
   collision, scales it to ten studs tall and places it on the plaza's left.
   The procedural kiosk is used when the template is missing or has no parts.
6. Save your Studio place. Imported meshes are not automatically part of the
   Rojo source tree; export the template as an `.rbxmx` or record uploaded asset
   IDs before distributing the place to another developer. Do not assume a
   command-line Rojo build includes your Studio-only template.

Importer documentation: https://create.roblox.com/docs/studio/importer

## Repeatable retrieval

Run `python3 scripts/meshy_kiosk.py status` to check existing tasks and
`python3 scripts/meshy_kiosk.py download` to download completed task files.
The script reads the local Meshy configuration without printing its API key.
`preview` and `refine` each create one paid task and refuse duplicates when their
IDs are already recorded. Do not delete the manifest and regenerate by accident.
