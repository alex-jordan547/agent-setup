#!/usr/bin/env python3
"""Run cleanup against temporary homes; optionally pass a PowerShell executable."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


repo = Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix="agent-setup-clean-") as temporary:
    root = Path(temporary)
    home = root / "test home"
    scripts = root / "scripts"
    scripts.mkdir()
    shutil.copyfile(repo / "config.env", root / "config.env")
    powershell = len(sys.argv) > 1
    source = repo / "scripts" / ("sync.ps1" if powershell else "sync.sh")
    script = scripts / source.name
    # Redirect only home lookups in the test copy, never the real process HOME.
    script.write_text(source.read_text().replace(
        "$env:USERPROFILE" if powershell else "$HOME",
        "$env:TEST_AGENT_HOME" if powershell else "$TEST_AGENT_HOME",
    ))
    command = ([sys.argv[1], "-NoProfile", "-File"] if powershell else ["/bin/bash"])
    command.append(str(script))

    def run(*flags, succeeds=True):
        result = subprocess.run(
            command + list(flags), capture_output=True, text=True,
            env={**os.environ, "TEST_AGENT_HOME": str(home)},
        )
        assert (result.returncode == 0) == succeeds, result.stdout + result.stderr
        return result.stdout

    def put(path, text="preserve me"):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def snapshot():
        return {
            str(p.relative_to(root)): ("link", os.readlink(p)) if p.is_symlink()
            else ("dir", "") if p.is_dir() else ("file", p.read_bytes())
            for p in root.rglob("*")
        }

    manifest = ".agent-setup-managed"
    shared = home / ".agents/skills"
    claude = home / ".claude/skills"
    codex = home / ".codex/skills"
    cursor = home / ".cursor/skills"
    xdg = home / ".config/opencode/skills"
    outside = root / "external target"
    put(outside / "SKILL.md")
    put(root / "skills/managed/SKILL.md")
    put(home / ".agents/AGENTS.md")
    put(home / ".claude/CLAUDE.md")
    put(home / ".codex/agents/scout.toml")
    put(home / ".codex/agents" / manifest, "scout.toml\n")
    for dest in (shared, claude, codex, cursor, xdg):
        put(dest / "external/SKILL.md")
    for dest in (shared, codex, xdg):
        put(dest / "managed/SKILL.md", "remove me")
        put(dest / manifest, "managed\n")
    put(cursor / "managed/SKILL.md")  # Matching name without ownership stays.
    put(codex / ".system/builtin/SKILL.md")
    (codex / manifest).write_bytes(b"managed\r\n")  # Native Windows manifest.
    (claude / "managed").symlink_to(shared / "managed", target_is_directory=True)
    (claude / "outside-link").symlink_to(outside, target_is_directory=True)
    (claude / "broken").symlink_to(root / "missing", target_is_directory=True)
    (claude / "unmanaged-link").symlink_to(shared / "managed", target_is_directory=True)
    put(claude / manifest, "managed\noutside-link\nbroken")  # No final newline.

    clean, dry, no_prune = ("-Clean", "-DryRun", "-NoPrune") if powershell else (
        "--clean", "--dry-run", "--no-prune")
    before = snapshot()
    preview = run(clean, dry)
    assert snapshot() == before, "dry-run changed files"
    for dest in (shared, claude, codex, cursor, xdg):
        assert f"keep (not managed by this repo): {dest / 'external'}" in preview
    assert str(codex / ".system") in preview
    assert f"keep (not managed by this repo): {codex / 'managed'}" not in preview
    run(clean, no_prune, succeeds=False)
    assert snapshot() == before, "conflicting flags changed files"
    run(clean)
    after = snapshot()
    removed = [shared / "managed", codex / "managed", xdg / "managed",
               claude / "managed", claude / "outside-link", claude / "broken"]
    removed += [dest / manifest for dest in (shared, claude, codex, xdg)]
    for path, value in before.items():
        absolute = root / path
        should_remove = any(absolute == p or p in absolute.parents for p in removed)
        assert (path not in after) if should_remove else (after.get(path) == value), path
    run(clean)
    assert snapshot() == after, "second cleanup changed files"
    for invalid in ("../escape", "/absolute", "..", ".system", "bad\\name", "C:bad"):
        put(shared / "managed/SKILL.md")
        put(shared / manifest, f"managed\n{invalid}\n")
        before = snapshot()
        run(clean, succeeds=False)
        assert snapshot() == before, f"invalid manifest deleted files: {invalid}"
    (shared / manifest).unlink()
    linked = home / ".linked/skills"
    linked.parent.mkdir()
    linked.symlink_to(outside, target_is_directory=True)
    put(outside / manifest, "SKILL.md\n")
    before = snapshot()
    run(clean, succeeds=False)
    assert snapshot() == before, "linked root changed files"

print("PASS: preview, retained entries, cleanup, links, repeat run, invalid manifests and flags")
