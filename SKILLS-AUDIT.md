# Audit des skills — 9 septembre 2026

**Proposition : 46 → 16 entrées dans le dépôt : 6 à garder, 10 à raccourcir, 30 à retirer comme skills indépendantes.** Les recettes et scripts distinctifs restent des références lorsque leur valeur le justifie. Le classement ci-dessous est celui de l’audit initial ; son application dans le dépôt est indiquée ci-dessous.

## Application dans le dépôt — 10 septembre 2026

16 skills actives : 6 conservées sans modification et 10 raccourcies. Les 30 autres dossiers sont déplacés, avec leurs ressources originales, dans `archive/2026-09-10/`. Les anciens dossiers déjà archivés sont préservés.

Les fichiers principaux passent de 5 199 à 527 lignes. Les recettes existantes restent accessibles ; le vocabulaire, les détails de gestes et les critères de revue sont regroupés comme références de motion. Ce chiffre ne mesure pas les tokens chargés par une session.

Validation : `python3 scripts/test-skills.py` vérifie les liens et un vrai sync Bash dans un dossier temporaire. Les 16 en-têtes sont validés, avec les champs d’invocation Claude existants contrôlés séparément. Les données externes/Hermes ci-dessous restent le relevé du 9 septembre.

Le sync global a ensuite été appliqué sur macOS : les 16 skills partagées correspondent aux sources et 14 liens Claude pointent vers elles. Les copies externes Claude de `install-anti-slop` et `no-ai-slop` sont conservées ; elles ne sont pas remplacées par les versions du dépôt. Les 4 fichiers de subagents Codex correspondent également aux sources. Les 951 fichiers/liens externes relevés avant le sync sont inchangés après celui-ci, y compris ceux de Hermes. Les plugins ne sont pas ciblés. Aucun ancien manifeste de skills n'était encore présent avant ce sync : aucune ancienne skill n'a été supprimée lors de cette exécution. Ces contrôles portent sur les fichiers installés, pas sur leur rechargement dans les sessions déjà ouvertes. PowerShell et WSL ne sont pas exécutés sur cette machine.

## Périmètre et niveau de preuve de l’audit initial (9 septembre)

- Dépôt : 46 fichiers `skills/*/SKILL.md`, 5 199 lignes ; 43 skills déjà archivées.
- Installations directes : 3 skills partagées, 4 Codex, 3 Claude, 3 Cursor. Soit 13 emplacements pour 10 noms distincts, hors système. Les 46 skills du dépôt ne sont plus synchronisées depuis le nettoyage.
- Hermes : 172 fichiers `SKILL.md` présents dans ses sous-dossiers, plus un lien vers ego-browser, soit 173 emplacements dans le CSV. Leur présence ne prouve pas leur activation.
- Plugins : recommandations par famille exposée dans cette conversation ; les fichiers en cache ne constituent pas une mesure d’usage.
- Dépôt : lecture des instructions, déclencheurs, structure et recouvrements. Les scripts embarqués ne sont pas tous exécutés ni audités ligne par ligne. Hermes : inventaire par domaine et lectures ciblées, verdicts provisoires.
- Pas de benchmark avec/sans skills ni d’historique d’invocation mesuré : aucun gain de qualité, latence ou coût n’est revendiqué. Les 5 199 lignes ne sont pas toutes chargées à chaque requête.

## Critère

Garder les connaissances que le modèle ne peut pas déduire du dépôt et des outils : procédures locales, pièges éprouvés, scripts, formats utiles et préférences produit. Retirer cours génériques, slogans, étapes imposées sans motif, références absentes et copies figées de documentation publique. Un meilleur modèle ne remplace ni un outil ni une preuve de validation.

Les [bonnes pratiques officielles de rédaction des skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) recommandent également de fournir seulement le contexte nécessaire et de charger les références à la demande. Cela motive le tri, sans prouver son efficacité sur nos tâches.

## Les 46 skills du dépôt

« Retirer » signifie supprimer le point d’entrée indépendant, avec conservation des références/scripts utiles. Les 16 restantes ne sont pas toutes à synchroniser globalement : les intégrations spécifiques peuvent rester locales ou explicitement invoquées.

| Skill | Lignes | Décision | Action |
|---|---:|---|---|
| [animate](/Users/alexjordan/Documents/Developer/agent-setup/skills/animate/SKILL.md) | 199 | Réduire | Garder les critères de mouvement web ; déplacer recettes, glossaire et grille de revue en références. Nuancer les interdictions absolues. |
| [animate-expo](/Users/alexjordan/Documents/Developer/agent-setup/skills/animate-expo/SKILL.md) | 255 | Réduire | Garder les particularités natives : runtimes, gestes, haptique, validation sur appareil ; recettes en références et API à vérifier selon le SDK. |
| [animation-vocabulary](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/animation-vocabulary/SKILL.md) | 173 | Retirer / fusionner | Fusionner le glossaire dans les références de animate. |
| [apple-design](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/apple-design/SKILL.md) | 282 | Retirer / fusionner | Conserver les recettes distinctives de gestes en référence, retirer le point d’entrée concurrent. |
| [ask-sonner](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/ask-sonner/SKILL.md) | 80 | Retirer / fusionner | Documentation de bibliothèque publique ; consulter la version utilisée plutôt que maintenir une copie globale. |
| [chrome-cdp](/Users/alexjordan/Documents/Developer/agent-setup/skills/chrome-cdp/SKILL.md) | 77 | Garder | CLI CDP réel et particularités de cibles/DPR/iframes. Garder en réserve explicite pour Chrome, pas comme navigateur par défaut. |
| [clean-code](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/clean-code/SKILL.md) | 201 | Retirer / fusionner | Redondant avec AGENTS.md/Ponytail ; plafond de 20 lignes, scripts externes non fournis et confirmations imposées. |
| [code-review](/Users/alexjordan/Documents/Developer/agent-setup/skills/code-review/SKILL.md) | 93 | Réduire | Garder conformité au besoin et défauts prouvés ; enlever deux agents obligatoires, setup absent et catalogue de smells. Inclure correction/sécurité/preuves. |
| [code-structure](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/code-structure/SKILL.md) | 116 | Retirer / fusionner | Cours générique sur les services. Les décisions d’architecture appartiennent aux ADR du dépôt. |
| [codex-orchestrator](/Users/alexjordan/Documents/Developer/agent-setup/skills/codex-orchestrator/SKILL.md) | 68 | Réduire | Garder propriété des fichiers, indépendance et intégration vérifiée ; retirer la matrice de modèles dupliquée avec les configurations. |
| [context7-auto-research](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/context7-auto-research/SKILL.md) | 36 | Retirer / fusionner | Explique surtout comment installer la skill elle-même ; aucune implémentation d’auto-recherche dans ce fichier. |
| [diagnosing-bugs](/Users/alexjordan/Documents/Developer/agent-setup/skills/diagnosing-bugs/SKILL.md) | 134 | Réduire | Garder reproduction, hypothèse vérifiable, mesure et revalidation ; retirer phases rigides et blocage de toute investigation avant un reproducer. |
| [eli5](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/eli5/SKILL.md) | 10 | Retirer / fusionner | Une consigne suffit ; visualize couvre la sortie visuelle. |
| [emil-design-eng](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/emil-design-eng/SKILL.md) | 679 | Retirer / fusionner | 679 lignes, large recouvrement avec animate/apple-design ; préserver les exemples distinctifs en référence. |
| [explain-diff](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/explain-diff/SKILL.md) | 84 | Retirer / fusionner | Recouvre visualize/show-me ; conserver le modèle de rapport si utile sans imposer du HTML à chaque explication. |
| [find-animation-opportunities](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/find-animation-opportunities/SKILL.md) | 132 | Retirer / fusionner | Fusionner le mode recherche d’opportunités dans animate. |
| [find-skills](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/find-skills/SKILL.md) | 142 | Retirer / fusionner | Pousse à chercher des skills sur des demandes ordinaires ; garder uniquement l’installation explicitement demandée via les outils existants. |
| [format-and-commit](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/format-and-commit/SKILL.md) | 58 | Retirer / fusionner | Commandes npm et organisation frontend/backend imposées ; utiliser les scripts du dépôt et la demande de commit. |
| [grill-me](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/grill-me/SKILL.md) | 7 | Retirer / fusionner | Simple alias qui lance grilling. |
| [grilling](/Users/alexjordan/Documents/Developer/agent-setup/skills/grilling/SKILL.md) | 12 | Garder | Préférence explicite utile et déjà courte : français, une question à la fois, explorer avant de demander. |
| [handoff](/Users/alexjordan/Documents/Developer/agent-setup/skills/handoff/SKILL.md) | 16 | Garder | Contrat compact de passation, références aux artefacts et absence de secrets. Invocation explicite. |
| [implement](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/implement/SKILL.md) | 15 | Retirer / fusionner | Reformule la demande d’implémentation et ajoute commit/renvois systématiques. |
| [implement-spec](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/implement-spec/SKILL.md) | 37 | Retirer / fusionner | Pipeline de worktrees et agents de merge obligatoire ; to-tickets + codex-orchestrator suffisent pour conserver les invariants utiles. |
| [improve-animations](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/improve-animations/SKILL.md) | 103 | Retirer / fusionner | Fusionner audit et références dans animate ; pas besoin d’un autre agent conseiller obligatoire. |
| [improve-codebase-architecture](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/improve-codebase-architecture/SKILL.md) | 72 | Retirer / fusionner | Audit générique et vocabulaire imposé, avec dépendances absentes. Une demande d’audit contextualisée suffit. |
| [install-anti-slop](/Users/alexjordan/Documents/Developer/agent-setup/skills/install-anti-slop/SKILL.md) | 91 | Garder | Installateur et sources de règles Oxlint : capacité exécutable. Garder pour installation explicitement demandée. |
| [no-ai-slop](/Users/alexjordan/Documents/Developer/agent-setup/skills/no-ai-slop/SKILL.md) | 97 | Réduire | Conserver voix de l’auteur, faits et quelques exemples ; retirer les longs catalogues et les consignes déjà globales. |
| [omniroute-contribution](/Users/alexjordan/Documents/Developer/agent-setup/skills/omniroute-contribution/SKILL.md) | 102 | Garder | Procédure et script propres au dépôt ; garder dans ce contexte et vérifier les règles courantes avant usage. |
| [performance-profiling](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/performance-profiling/SKILL.md) | 143 | Retirer / fusionner | Rappels génériques ; préserver séparément le script de profiling s’il est utile, ou utiliser les outils existants. |
| [pick-ui-library](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/pick-ui-library/SKILL.md) | 77 | Retirer / fusionner | Liste fermée de dépendances ; partir de celles installées, du besoin et des docs actuelles. |
| [pr-ready](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/pr-ready/SKILL.md) | 40 | Retirer / fusionner | Base master codée en dur et /verify non fourni ; conventions/commandes à lire dans le dépôt. |
| [prototype](/Users/alexjordan/Documents/Developer/agent-setup/skills/prototype/SKILL.md) | 31 | Garder | Contrat utile : expérience jetable répondant à une question, lancement simple et limites explicites. |
| [react-doctor](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/react-doctor/SKILL.md) | 19 | Retirer / fusionner | Essentiellement une commande. En faire un contrôle optionnel de dépôt plutôt qu’une obligation globale après toute modification React. |
| [research](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/research/SKILL.md) | 12 | Retirer / fusionner | Sources primaires déjà demandées globalement ; agent en arrière-plan imposé. |
| [resolving-merge-conflicts](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/resolving-merge-conflicts/SKILL.md) | 14 | Retirer / fusionner | Rappel générique ; conventions Git locales à garder dans les instructions du dépôt. |
| [review-animations](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/review-animations/SKILL.md) | 112 | Retirer / fusionner | Fusionner la grille de revue dans animate/animate-expo, garder les références utiles. |
| [simplify](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/simplify/SKILL.md) | 54 | Retirer / fusionner | Trois agents imposés pour une simplification. Une demande directe ou Ponytail suffit. |
| [tdd](/Users/alexjordan/Documents/Developer/agent-setup/skills/tdd/SKILL.md) | 108 | Réduire | Garder le mode explicite test-first et le test comportemental ; retirer confirmations multiples et dépendance codebase-design. |
| [teach](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/teach/SKILL.md) | 140 | Retirer / fusionner | Dispositif pédagogique persistant trop spécifique pour le kit de développement ; archiver et réactiver pour un vrai cursus. |
| [to-spec](/Users/alexjordan/Documents/Developer/agent-setup/skills/to-spec/SKILL.md) | 75 | Réduire | Modèle court problème/décision/critères/limites ; supprimer longue liste de user stories et setup imposés. |
| [to-tickets](/Users/alexjordan/Documents/Developer/agent-setup/skills/to-tickets/SKILL.md) | 114 | Réduire | Garder livraisons vérifiables et dépendances ; retirer setup absent, formats redondants et questionnaires systématiques. |
| [triage](/Users/alexjordan/Documents/Developer/agent-setup/skills/triage/SKILL.md) | 112 | Réduire | Garder états et vérification ; lire les labels du projet, retirer disclaimer imposé et dépendances de setup/domain-modeling. |
| [typescript-expert](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/typescript-expert/SKILL.md) | 429 | Retirer / fusionner | 429 lignes de cours générique et renvois vers des experts absents ; scripts de validation risquant de lancer un autre runner après un échec. |
| [verification-before-completion](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/verification-before-completion/SKILL.md) | 139 | Retirer / fusionner | Garder la règle de preuve dans AGENTS.md, retirer 139 lignes répétitives. La vérification reste obligatoire. |
| [wayfinder](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/wayfinder/SKILL.md) | 127 | Retirer / fusionner | Processus lourd de cartes/issues et dépendances absentes ; plan proportionné + to-spec/to-tickets. |
| [writing-great-skills](/Users/alexjordan/Documents/Developer/agent-setup/archive/2026-09-10/writing-great-skills/SKILL.md) | 82 | Retirer / fusionner | Redondant avec skill-creator ; conserver les idées utiles de concision/références dans une seule source. |

## Preuves prioritaires

- `clean-code`, ligne 44 : maximum de 20 lignes par fonction ; ligne 150 et suivantes : scripts externes ; ligne 195 : attendre avant de corriger.
- `typescript-expert`, ligne 28 : s’arrêter pour appeler un autre expert ; ligne 58 : `npm test -s || npx vitest ...` peut lancer un second runner au lieu de traiter l’échec du premier.
- `pr-ready`, ligne 13 : `/verify` ; lignes 21–23 : base `master`.
- `simplify`, ligne 17 : trois agents parallèles imposés.
- `to-spec`, lignes 33 et 41 : longue liste de user stories imposée quelle que soit la taille de la demande.
- `setup-matt-pocock-skills`, `codebase-design`, `domain-modeling` et `verify` ne sont fournis ni dans ce dépôt ni comme skills dans le catalogue actuel de cette conversation.

## Installations externes : verdict

| Skill | Décision | Pourquoi |
|---|---|---|
| portly | Garder | Protocole et gestion des serveurs locaux ; CLI détecté. |
| ego-browser | Garder | API spécifique du navigateur ; fichier fourni par l’application. Ne pas modifier la copie fournisseur. |
| remote-app-network-rescue | Garder | Diagnostic local/distant, proxy/TLS et streaming avec scripts spécifiques. |
| frontend-skill | Réduire | Préférences visuelles utiles ; éviter de généraliser les contraintes de landing page aux interfaces produit. |
| playwright | Garder en réserve | Wrapper et automatisation au terminal ; invocation explicite, un seul navigateur par défaut. |
| show-me | Retirer / fusionner | Recouvre visualize ; conserver seulement les exemples distinctifs si nécessaires. |
| editor | Désactiver par défaut | Intégration réelle de Diffusion Studio, mais dapi absent du PATH inspecté ; garder si cet outil vidéo est souhaité. Cela ne prouve pas une absence totale d’installation. |
| install-anti-slop | Garder | Même verdict que le dépôt ; comparer avant de centraliser les copies Claude/Cursor. |
| no-ai-slop | Réduire | Même verdict que le dépôt ; comparer les copies avant harmonisation. |
| thermo-nuclear-code-quality-review | Retirer | Encourage les restructurations ambitieuses et recouvre la revue normale ; tension avec l’objectif de petits diffs. |

## Hermes : périmètre distinct

**Résidu confirmé :** `/Users/alexjordan/.hermes/skills/openclaw-imports/mmx-cli/SKILL.md` existe encore. Le nettoyage précédent couvrait les entrées directes et avait raté cette copie imbriquée. Elle reste à retirer conformément à la demande précédente ; aucune suppression pendant cet audit.

| Ensemble | Recommandation |
|---|---|
| CEL, backups, restauration, déploiement, identité et accès distant | Garder localement : procédures propres aux systèmes. Les commandes de production n’ont pas été validées par cet inventaire. |
| fireworks-hermes-setup / hermes-fireworks-setup | Fusionner après vérification du comportement actuel : même sujet et exemples différents de noms de modèles. |
| simplify-code | Retirer ou réduire : quatre agents imposés pour une simplification. |
| plan / writing-plans / subagent-driven-development / multi-agent-development-orchestration | Réduire à un mode de planification et un mode de délégation ; supprimer les pipelines systématiques. |
| Revue, PR et communication | Fusionner les checklists génériques, garder les conventions propres aux projets. |
| Secrets, sauvegardes et commandes sûres | Garder les protections ; ne fusionner que les répétitions démontrées. |
| MLOps, médias, Apple, domotique, jeux, services tiers | À la demande selon les outils utilisés. Pas de données d’usage collectées permettant d’affirmer leur inutilité. |

Inventaire par famille, fichiers présents (les contenus de toutes ces skills n’ont pas été audités en détail) :

- **apple (4)** : `apple-notes`, `apple-reminders`, `findmy`, `imessage`.
- **autonomous-ai-agents (10)** : `claude-code`, `codex`, `computer-use`, `fireworks-hermes-setup`, `hermes-agent`, `hermes-config-audit`, `hermes-cron-operations`, `hermes-fireworks-setup`, `merge-reconciler`, `opencode`.
- **cel (6)** : `cel-convex-restore-collision-recovery`, `cel-deployment-operations`, `cel-free-agent-count-debugging`, `cel-hermes-backup-cron`, `cel-player-stats-add-button`, `cel-premium-monetization`.
- **communication (3)** : `discord-server-administration`, `job-application-positioning`, `profile-aware-messaging`.
- **creative (17)** : `architecture-diagram`, `ascii-art`, `ascii-video`, `baoyu-infographic`, `claude-design`, `comfyui`, `creative-ideation`, `design-md`, `excalidraw`, `humanizer`, `manim-video`, `p5js`, `popular-web-designs`, `pretext`, `sketch`, `songwriting-and-ai-music`, `touchdesigner-mcp`.
- **data-science (1)** : `jupyter-live-kernel`.
- **devops (11)** : `container-runtime-troubleshooting`, `containerized-service-installation`, `convex-data-migrations`, `convex-selfhosted-postgres-export-and-user-list`, `convex-selfhosted-postgres-migrations`, `remote-development-access`, `remote-host-ssh-access`, `sdlc-review`, `secret-safe-commands`, `telegram-large-file-transfer`, `webhook-subscriptions`.
- **email (3)** : `email-alert-automation`, `email-inbox-triage`, `himalaya`.
- **gaming (2)** : `minecraft-modpack-server`, `pokemon-player`.
- **github (8)** : `github-auth`, `github-code-review`, `github-issue-to-pr`, `github-issues`, `github-pr-workflow`, `github-repo-management`, `oss-pr-maintainer-workflow`, `pull-request-finalization`.
- **leisure (1)** : `find-nearby`.
- **mcp (3)** : `mcp-registry-publishing`, `mcporter`, `native-mcp`.
- **media (5)** : `gif-search`, `heartmula`, `songsee`, `sports-video-event-extraction`, `youtube-content`.
- **mlops (23)** : `audiocraft`, `axolotl`, `clip`, `dspy`, `evaluating-llms-harness`, `gguf`, `grpo-rl-training`, `guidance`, `huggingface-hub`, `llama-cpp`, `llm-gateway-routing`, `modal`, `obliteratus`, `outlines`, `peft`, `pytorch-fsdp`, `segment-anything`, `serving-llms-vllm`, `stable-diffusion`, `trl-fine-tuning`, `unsloth`, `weights-and-biases`, `whisper`.
- **note-taking (1)** : `obsidian`.
- **openclaw-imports (1)** : `mmx-cli`.
- **productivity (24)** : `airtable`, `analytical-report-delivery`, `box`, `browser-profile-sync-migration`, `daily-cockpit-report`, `document-to-action-items`, `docx`, `google-workspace`, `linear`, `maps`, `meeting-action-items`, `nano-pdf`, `notion`, `ocr-and-documents`, `pdf`, `petdex`, `powerpoint`, `product-price-monitor`, `reminder-routing`, `session-librarian`, `teams-meeting-pipeline`, `tui-widgets`, `weekly-review-planning`, `xlsx`.
- **racine (8)** : `dogfood`, `handling-secrets-in-tool-calls`, `hermes-desktop-plugins`, `hermes-themes`, `pr-review-worktree`, `self-hosted-ai-gateway`, `whatsapp-remote-pairing`, `yuanbao`.
- **red-teaming (1)** : `godmode`.
- **research (11)** : `arxiv`, `blogwatcher`, `competitor-news-monitor`, `consumer-product-recommendations`, `grounded-citations`, `llm-wiki`, `polymarket`, `regional-market-fit-monetization`, `research-paper-writing`, `resilient-web-research`, `saas-reseller-due-diligence`.
- **smart-home (1)** : `openhue`.
- **social-media (2)** : `xitter`, `xurl`.
- **software-development (25)** : `cel-club-roster-debugging`, `cel-git-workflow`, `cel-prod-public-vs-runner-debugging`, `cel-user-identity-username-safety`, `codebase-inspection`, `engineering-delivery-communication`, `github`, `hermes-agent-skill-authoring`, `independent-pre-push-review`, `inspecting-hermes-desktop-dom`, `multi-agent-development-orchestration`, `node-inspect-debugger`, `parallel-agent-worktrees`, `plan`, `protocol-proxy-compatibility`, `python-debugpy`, `renpy-runtime-debugging`, `requesting-code-review`, `simplify-code`, `spike`, `subagent-driven-development`, `systematic-debugging`, `test-driven-development`, `vite-react-i18n-review`, `writing-plans`.
- **web (1)** : `blocked-page-recovery`.

## Plugins et système

Conserver les intégrations maintenues par les fournisseurs ; désactiver celles inutilisées via leur gestionnaire plutôt que réécrire leurs caches.

| Famille | Décision |
|---|---|
| Expo | Garder pour les projets Expo : outils et différences de versions utiles. |
| Figma | Garder si utilisé ; les prérequis et contrats MCP ne sont pas de simples conseils de style. |
| Cloudflare | Garder sur les projets concernés, à la demande ailleurs. |
| Remotion | Garder pour la vidéo en code, à la demande ; différent de Diffusion Studio. |
| PostHog | Garder sur les projets qui l’utilisent. |
| Sites | Garder pour les sites gérés par Sites. |
| Visualize | Garder comme entrée principale des explications visuelles. |
| Deep research | Garder en invocation explicite pour les recherches longues. |
| Imagegen | Garder, intégration de génération d’images. |
| Ponytail | Garder la préférence de simplicité ; réduire les répétitions et obligations automatiques globales. Ne pas modifier le cache fournisseur. |
| openai-docs, skill-creator, skill-installer, plugin-creator, review-agent interne sur disque | Conserver comme composants de l’environnement, distincts des skills personnelles. |

## Archives

43 skills sont déjà hors sync. Pas de purge urgente : elles ne constituent pas 43 skills actives. `animation-vocabulary` et `review-animations` existent à la fois dans skills et archive ; comparer avant de déplacer une nouvelle version, sans écraser les anciennes.

`animation-vocabulary`, `brandkit`, `canvas-design`, `code-review-checklist`, `convex`, `convex-dev-resend`, `convex-dev-stripe`, `convex-migration-helper`, `convex-performance-audit`, `convex-quickstart`, `convex-setup-auth`, `design-taste-frontend`, `frontend-responsive-design-standards`, `frontier-orchestrator`, `gpt-taste`, `grill-with-docs`, `health`, `high-end-visual-design`, `image-to-code`, `imagegen-frontend-mobile`, `imagegen-frontend-web`, `minimalist-ui`, `nextjs-best-practices`, `open-orchestrator-cheap`, `open-orchestrator-medium`, `react-email`, `redesign-existing-projects`, `review-animations`, `scroll-experience`, `speckit-analyze`, `speckit-checklist`, `speckit-clarify`, `speckit-constitution`, `speckit-implement`, `speckit-plan`, `speckit-specify`, `speckit-tasks`, `speckit-taskstoissues`, `tailwindcss-mobile-first`, `thermo-nuclear-code-quality-review`, `use-loop`, `using-superpowers`, `wevehiculegen2-as-simulator`.

## Suite proposée

1. Retirer les 30 points d’entrée proposés, préserver les références/scripts utiles et mettre à jour tous les renvois entrants.
2. Réduire les 10 retenus : procédure spécifique compacte, références à la demande ; pas de plafond arbitraire de lignes.
3. Garder un navigateur par défaut et une entrée visuelle. Les autres intégrations restent en réserve explicite.
4. Traiter séparément les copies externes et Hermes, avec distinction entre fichiers personnels et composants fournis par les applications.
5. Vérifier liens et références, puis synchroniser seulement le sous-ensemble choisi. Après cette révision, le sync installe les 16 skills retenues.
6. Comparer quelques tâches représentatives avant/après : bug, revue, UI et tickets. Mesurer réussite, preuves, interruptions inutiles et effort ; réintroduire une instruction seulement en cas de régression observable.

L’audit du 9 septembre était sans modification. Les décisions concernant le dépôt ont été appliquées le 10 septembre comme indiqué en tête ; les recommandations externes et Hermes restent séparées.
