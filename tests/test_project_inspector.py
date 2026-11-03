#!/usr/bin/env python3
"""Exercise the read-only project inspector using only disposable local fixtures."""
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLI = ROOT / "scripts" / "mew"


def inventory(path, *options, ok=True):
    result = subprocess.run([str(CLI), "inspect", "project", str(path), "--json", *options], capture_output=True, text=True)
    assert (result.returncode == 0) == ok, (result.returncode, result.stdout, result.stderr)
    return json.loads(result.stdout) if ok else result


def snapshot(root):
    results = {}
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            results[relative] = ("link", os.readlink(path))
        elif path.is_file():
            results[relative] = ("file", hashlib.sha256(path.read_bytes()).hexdigest())
        elif path.is_dir():
            results[relative] = ("dir", "")
    return results


def main():
    with tempfile.TemporaryDirectory(prefix="mew-inspector-") as temporary:
        root = Path(temporary) / "Website project"
        root.mkdir()
        (root / "package.json").write_text(json.dumps({"dependencies": {"next": "15", "react": "19"}, "scripts": {"postinstall": "touch should-not-run"}, "private": "SECRET_INSPECTION_TEST"}))
        (root / ".env").write_text("SECRET_INSPECTION_TEST")
        (root / "package-lock.json").write_text("SECRET_INSPECTION_TEST")
        (root / "src").mkdir()
        (root / "src" / "page.tsx").write_text("export default function Page() {}")
        (root / "backend").mkdir()
        (root / "backend" / "requirements.txt").write_text("Django>=4\nfastapi==1\n--index-url https://private.example/SECRET_INSPECTION_TEST\n")
        (root / "node_modules").mkdir()
        (root / "node_modules" / "package.json").write_text('{"dependencies":{"express":"1"}}')
        outside = Path(temporary) / "outside"
        outside.mkdir()
        (outside / "composer.json").write_text('{"require":{"laravel/framework":"1"}}')
        (root / "external-link").symlink_to(outside, target_is_directory=True)
        (root / "composer.json").symlink_to(outside / "composer.json")
        before = snapshot(root)

        report = inventory(root)
        assert report["schema"] == "mew-project-inspection/v1" and report["mode"] == "read_only"
        assert {item["name"] for item in report["framework_evidence"]} == {"next.js", "react", "django", "fastapi"}
        assert report["source_file_counts"]["typescript"] == 1
        assert {item["kind"] for item in report["markers"]} >= {"node_manifest", "npm_lock", "python_requirements"}
        encoded = json.dumps(report)
        assert "SECRET_INSPECTION_TEST" not in encoded and "postinstall" not in encoded
        assert "laravel" not in encoded and "express" not in encoded
        assert report["scope"]["skipped_symlinks"] == 2
        assert "database connection" in report["not_verified"]
        assert snapshot(root) == before and not (root / "should-not-run").exists()

        shallow = inventory(root, "--max-depth", "0")
        assert shallow["scope"]["depth_limited"] is True
        assert "python_requirements" not in {item["kind"] for item in shallow["markers"]}
        inventory(root, "--max-depth", "9", ok=False)
        inventory(root / "missing", ok=False)

        broken = Path(temporary) / "broken"
        broken.mkdir()
        (broken / "package.json").write_text("not valid json")
        (broken / "composer.json").write_text("x" * (256 * 1024 + 1))
        report = inventory(broken)
        assert {item["kind"] for item in report["warnings"]} == {"manifest_invalid", "manifest_unreadable_or_too_large"}

        large = Path(temporary) / "large"
        large.mkdir()
        for index in range(5001):
            (large / ("file-" + str(index))).touch()
        report = inventory(large)
        assert report["scope"]["truncated"] and report["scope"]["visited_entries"] == 5000

    print("Project inspector integration tests passed.")


if __name__ == "__main__":
    main()
