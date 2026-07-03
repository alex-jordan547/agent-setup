# agent-setup

Source de vérité versionnée pour mes skills d'agents (Claude Code + Codex), synchronisée vers tous les emplacements sur WSL, Windows et macOS.

Créé après avoir perdu des skills lors d'un remplacement de distro WSL (2026-07-01) — plus jamais ça.

## Layout

| Chemin | Rôle |
|---|---|
| `skills/` | toutes les skills (une par dossier, `SKILL.md` + assets) |
| `config.env` | `WINDOWS_USER` + `CODEX_SKILLS` (le sous-ensemble copié dans `.codex/skills`) |
| `scripts/sync.sh` | sync Linux / WSL / macOS (bash 3.2 compatible) |
| `scripts/sync.ps1` | sync Windows natif (PowerShell + robocopy) |
| `shell/env.sh` | exports d'environnement (ex. `CDP_PORT_FILE` pour chrome-cdp sous WSL) |

## Destinations

- `~/.agents/skills` : **toutes** les skills (répertoire standard cross-outils)
- `~/.codex/skills` : uniquement `CODEX_SKILLS`
- Sous WSL, les deux mêmes répertoires côté Windows (`/mnt/c/Users/$WINDOWS_USER/…`) sont aussi synchronisés — pas besoin de lancer `sync.ps1` si le WSL tourne.

Chaque destination reçoit un manifeste `.agent-setup-managed` : seules les entrées listées dedans peuvent être supprimées (prune). Les skills installées par d'autres outils (gstack, `npx skills`, …) ne sont jamais touchées.

## Usage

```bash
./scripts/sync.sh --dry-run   # voir ce qui serait fait
./scripts/sync.sh             # sync + prune
./scripts/sync.sh --no-prune  # sync sans suppression
```

Windows natif (sans WSL) :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File scripts\sync.ps1
```

Nouvelle machine :

```bash
git clone <ce repo> && cd agent-setup && ./scripts/sync.sh
echo 'source ~/Documents/Developper/agent-setup/shell/env.sh' >> ~/.zshrc
```

## Workflow

1. Modifier/ajouter une skill dans `skills/`
2. `./scripts/sync.sh`
3. `git add -A && git commit && git push`

Ne jamais éditer directement dans `~/.agents/skills` ou `~/.codex/skills` : le prochain sync écrase (rsync `--delete` / robocopy `/MIR`).

## Notes

- Les skills `gstack-*`/gstack sont aussi gérées par l'outil gstack ; si gstack les met à jour, réimporter ici (`rsync ~/.agents/skills/<name>/ skills/<name>/`) ou retirer du repo pour laisser gstack seul maître.
- Les copies d'agent-guards (orchestrator, use-loop, self-test, …) sont des versions patchées (chemins de preuves `~/.codex/proofs/`, pas de chemins absolus de l'auteur).
