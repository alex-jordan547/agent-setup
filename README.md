# agent-setup

Source de vérité versionnée pour mes skills d'agents (Claude Code + Codex), synchronisée vers tous les emplacements sur WSL, Windows et macOS.

Créé après avoir perdu des skills lors d'un remplacement de distro WSL (2026-07-01) — plus jamais ça.

## Layout

| Chemin | Rôle |
|---|---|
| `skills/` | les skills actives (une par dossier, `SKILL.md` + assets) |
| `archive/` | anciennes skills hors sync, dont le retrait du 10 septembre dans `archive/2026-09-10/` |
| `agents/` | subagents Codex custom (`*.toml`, synced vers `~/.codex/agents`) |
| `CLAUDE.md` | mémoire globale Claude Code (source de vérité, synced vers `~/.claude/CLAUDE.md`) |
| `AGENTS.md` | mémoire globale des autres agents (synced vers `~/.agents/AGENTS.md`) |
| `config.env` | `WINDOWS_USER` |
| `scripts/sync.sh` | sync Linux / WSL / macOS (bash 3.2 compatible) |
| `scripts/sync.ps1` | sync Windows natif (PowerShell + robocopy) |
| `shell/env.sh` | exports d'environnement (ex. `CDP_PORT_FILE` pour chrome-cdp sous WSL) |

## Catalogue

Le catalogue contient **16 skills**. Six sont conservées telles quelles :
`chrome-cdp`, `grilling`, `handoff`, `install-anti-slop`,
`omniroute-contribution`, `prototype`.

Dix ont été raccourcies : `animate`, `animate-expo`, `code-review`,
`codex-orchestrator`, `diagnosing-bugs`, `no-ai-slop`, `tdd`, `to-spec`,
`to-tickets`, `triage`.

Les 30 autres entrées et leurs ressources originales sont conservées dans
`archive/2026-09-10/`. Elles ne sont plus synchronisées. Les recettes de motion
restent dans `animate` et `animate-expo` ; le vocabulaire, les détails de gestes
et les critères de revue sont accessibles à la demande depuis leurs fichiers
`SKILL.md`. Aucun fichier `SKILL.md` supplémentaire n'est créé pour ces références.

Pour restaurer une entrée, déplacer son dossier exact depuis l'archive vers
`skills/`, vérifier ses références et lancer un aperçu du sync avant application.
Ne pas écraser une version déjà présente.

Vérifier le catalogue et une synchronisation dans un dossier temporaire :

```bash
python3 scripts/test-skills.py
```

Ce contrôle nécessite Python 3.9+, Bash et rsync. Il vérifie les liens locaux,
la copie des ressources, les manifestes, les liens Claude et la conservation des
skills externes. Il ne modifie pas les installations globales.

## Destinations

Skills :

- `~/.agents/skills` : **toutes** les skills (répertoire standard cross-outils)
- `~/.claude/skills` : symlinks vers les skills gérées dans `~/.agents/skills`, pour Claude Code
- `~/.codex/agents` : les subagents Codex (`agents/*.toml`)
- Chaque destination reçoit un manifeste `.agent-setup-managed` : seules les entrées listées dedans peuvent être supprimées (prune). Les skills/agents installés par d'autres outils ne sont jamais touchés.

Mémoire globale (repo = source de vérité) :

- `CLAUDE.md` → `~/.claude/CLAUDE.md`
- `AGENTS.md` → `~/.agents/AGENTS.md`
- Avant tout écrasement, l'ancien fichier cible est sauvegardé en `<chemin>.bak-<AAAAMMJJ-HHMMSS>` (uniquement s'il diffère). Pas de backup pour les skills.

Sous WSL, les mêmes destinations côté Windows (`/mnt/c/Users/$WINDOWS_USER/…`) sont aussi synchronisées — pas besoin de lancer `sync.ps1` si le WSL tourne.

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

### Nettoyer les skills gérées

```bash
./scripts/sync.sh --clean --dry-run  # aperçu des suppressions et des entrées conservées
./scripts/sync.sh --clean            # retirer toutes les skills gérées par ce dépôt
```

Windows natif :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 -Clean -DryRun
powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 -Clean
```

Le nettoyage recherche les dossiers globaux `~/.*/skills` et `~/.config/*/skills`
(également côté Windows sous WSL), puis supprime uniquement les entrées inscrites
dans leur manifeste `.agent-setup-managed`, ainsi que ce manifeste. Cela couvre
les installations actuelles et les anciennes copies gérées dans `~/.codex/skills`.
Les liens sont retirés sans supprimer leurs cibles externes.

Chaque entrée hors manifeste est affichée avec `keep (not managed by this repo)`
et conservée, même si elle porte le nom d'une skill présente dans le dépôt.
Un lien hors manifeste reste en place même si sa cible fait partie des skills supprimées.
Les skills intégrées aux plugins et les installations propres aux projets ne sont
pas parcourues. Les sources `skills/`, les subagents et les fichiers mémoire restent
intacts. Relancer le sync normal réinstalle les skills du dépôt ; `--clean` et
`--no-prune` ne peuvent pas être combinés.

Test isolé : `python3 scripts/test-clean.py` (Bash), ou
`python3 scripts/test-clean.py pwsh` (PowerShell installé).

Nouvelle machine :

```bash
git clone <ce repo> && cd agent-setup && ./scripts/sync.sh
echo 'source ~/Documents/Developper/agent-setup/shell/env.sh' >> ~/.zshrc
```

## Workflow

1. Modifier/ajouter une skill dans `skills/`
2. `./scripts/sync.sh`
3. `git add -A && git commit && git push`

Ne jamais éditer directement dans les skills gérées sous `~/.agents/skills` ou `~/.claude/skills`, ni dans `~/.claude/CLAUDE.md` ou `~/.agents/AGENTS.md` : le prochain sync écrase les skills gérées (rsync `--delete` / robocopy `/MIR`) ; les fichiers mémoire sont sauvegardés avant écrasement.

## Notes

- Les copies d'agent-guards (orchestrator, use-loop, self-test, …) sont des versions patchées (chemins de preuves `~/.codex/proofs/`, pas de chemins absolus de l'auteur).
