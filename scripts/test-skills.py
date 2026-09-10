#!/usr/bin/env python3
"""Check skill references and sync the real catalog into a temporary home."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit


repo = Path(__file__).resolve().parent.parent
source = repo / "skills"
names = {p.name for p in source.iterdir() if p.is_dir()}
assert names, "empty catalog"
assert all((source / name / "SKILL.md").is_file() for name in names)


def check_links(root):
    checked = 0
    for path in root.rglob("*.md"):
        text = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
        for target in re.findall(r"\[[^\]]*\]\(([^\s)]+)\)", text):
            url = urlsplit(target)
            if url.scheme or not url.path:
                continue
            linked = (path.parent / unquote(url.path)).resolve()
            assert linked.is_relative_to(root.resolve()), (path, target)
            assert linked.exists(), (path, target)
            checked += 1
    return checked


links = check_links(source)
with tempfile.TemporaryDirectory(prefix="agent-setup-skills-") as temporary:
    root = Path(temporary)
    fixture = root / "repo"
    home = root / "home"
    (fixture / "scripts").mkdir(parents=True)
    shutil.copytree(source, fixture / "skills")
    shutil.copytree(repo / "agents", fixture / "agents")
    for name in ("config.env", "AGENTS.md", "CLAUDE.md"):
        shutil.copyfile(repo / name, fixture / name)
    # Redirect home lookups in the test copy, without changing the process HOME.
    # Redirect Windows roots as well so the test is isolated when run under WSL.
    script = (repo / "scripts/sync.sh").read_text().replace(
        "$HOME", "$TEST_AGENT_HOME"
    ).replace("/mnt/c/Users", str(root / "windows"))
    (fixture / "scripts/sync.sh").write_text(script)
    shared = home / ".agents/skills"
    claude = home / ".claude/skills"
    shared.mkdir(parents=True)
    claude.mkdir(parents=True)
    stale = "retired-test-skill"
    (shared / stale).mkdir()
    (shared / stale / "SKILL.md").write_text("previously managed")
    (claude / stale).symlink_to(shared / stale, target_is_directory=True)
    for dest in (shared, claude):
        (dest / ".agent-setup-managed").write_text(stale + "\n")
        (dest / "external").mkdir()
        (dest / "external/SKILL.md").write_text("external skill")
    archived = fixture / "archive" / stale
    archived.mkdir(parents=True)
    (archived / "SKILL.md").write_text("do not sync")

    result = subprocess.run(
        ["/bin/bash", str(fixture / "scripts/sync.sh")],
        env={**os.environ, "TEST_AGENT_HOME": str(home)},
        capture_output=True, text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    for dest in (shared, claude):
        manifest = set((dest / ".agent-setup-managed").read_text().splitlines())
        assert manifest == names, (dest, manifest)
        assert not (dest / stale).exists() and not (dest / stale).is_symlink()
        assert (dest / "external/SKILL.md").read_text() == "external skill"
        assert {p.name for p in dest.iterdir() if p.is_dir()} == names | {"external"}
    for name in names:
        assert (claude / name).is_symlink()
        assert (claude / name).resolve() == (shared / name).resolve()
    for path in source.rglob("*"):
        if path.is_file() and path.name != ".DS_Store":
            assert (shared / path.relative_to(source)).read_bytes() == path.read_bytes()
    check_links(shared)
    assert (archived / "SKILL.md").read_text() == "do not sync"

print(f"PASS: {len(names)} skills, {links} local links, real sync, pruning and external preservation")
