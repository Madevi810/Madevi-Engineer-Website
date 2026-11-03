#!/usr/bin/env python3
"""Integration tests for MEW's portable skill and one-shot HTTP probe."""
import json
import os
import shutil
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLI = ROOT / "scripts" / "mew"
PACKAGE = ROOT / "integrations" / "agent-skills" / "mew-website-engineer"


class Handler(BaseHTTPRequestHandler):
    hits = []

    def do_GET(self):
        self.hits.append(self.path)
        status = 302 if self.path == "/redirect" else 503 if self.path == "/fail" else 200
        self.send_response(status)
        if status == 302:
            self.send_header("Location", "/followed")
        self.end_headers()
        self.wfile.write(b"test")

    def log_message(self, *_args):
        pass


def run(*args, cwd=None, ok=True, env=None):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=False, env=env)
    assert (result.returncode == 0) == ok, (args, result.returncode, result.stdout, result.stderr)
    return result


def main():
    skill = (PACKAGE / "SKILL.md").read_text()
    assert skill.startswith("---\nname: mew-website-engineer\ndescription: ")
    for path in ("references/engineering.md", "references/live-operations.md", "scripts/health-check.sh", "scripts/watch-http.sh"):
        assert path in skill and (PACKAGE / path).is_file()

    with tempfile.TemporaryDirectory(prefix="mew-skill-test-") as temp:
        temp = Path(temp)
        project = temp / "existing project"
        project.mkdir()
        (project / "AGENTS.md").write_text("Existing project rules\n")
        target = project / ".agents" / "skills" / "mew-website-engineer"
        run(str(CLI), "skill", "install", "--project", str(project), "--dry-run")
        assert not target.exists()
        run(str(CLI), "skill", "install", "--project", str(project))
        assert (target / "SKILL.md").read_text() == skill

        # Fail the second move (new skill activation); the original must be restored.
        rollback_project = temp / "rollback-project"
        rollback_project.mkdir()
        run(str(CLI), "skill", "install", "--project", str(rollback_project))
        rollback_target = rollback_project / ".agents/skills/mew-website-engineer"
        (rollback_target / "custom.txt").write_text("preserve")
        mv_bin = temp / "mv-bin"
        mv_bin.mkdir()
        fake_mv = mv_bin / "mv"
        fake_mv.write_text("#!/bin/sh\nn=$(cat \"$MEW_MOVE_STATE\" 2>/dev/null || printf 0)\nn=$((n+1))\nprintf '%s' \"$n\" > \"$MEW_MOVE_STATE\"\n[ \"$n\" -ne 2 ] || exit 1\nexec \"$MEW_REAL_MV\" \"$@\"\n")
        fake_mv.chmod(0o755)
        env = dict(os.environ, PATH=str(mv_bin) + os.pathsep + os.environ["PATH"], MEW_MOVE_STATE=str(temp / "move-state"), MEW_REAL_MV=shutil.which("mv"))
        run(str(CLI), "skill", "update", "--project", str(rollback_project), ok=False, env=env)
        assert (rollback_target / "custom.txt").read_text() == "preserve"
        assert "Material Catalog Model" in run(str(CLI), "library", "materials", cwd=project).stdout
        assert str(ROOT) == run(str(CLI), "library", "path", cwd=project).stdout.strip()
        assert (project / "AGENTS.md").read_text() == "Existing project rules\n"
        (target / "keep.txt").write_text("keep")
        run(str(CLI), "skill", "install", "--project", str(project), ok=False)
        assert (target / "keep.txt").read_text() == "keep"
        run(str(CLI), "skill", "update", "--project", str(project), "--dry-run")
        assert (target / "keep.txt").read_text() == "keep"
        run(str(CLI), "skill", "update", "--project", str(project))
        assert not (target / "keep.txt").exists()
        backups = list((project / ".agents/mew-backups").glob("mew-website-engineer.*/previous/keep.txt"))
        assert len(backups) == 1 and backups[0].read_text() == "keep"
        assert (target / "SKILL.md").read_text() == skill

        linked = temp / "linked-project"
        linked.mkdir()
        (linked / ".agents").symlink_to(project / ".agents", target_is_directory=True)
        run(str(CLI), "skill", "install", "--project", str(linked), ok=False)
        backup_linked = temp / "linked-backup-project"
        backup_linked.mkdir()
        run(str(CLI), "skill", "install", "--project", str(backup_linked))
        (backup_linked / ".agents/mew-backups").symlink_to(project, target_is_directory=True)
        run(str(CLI), "skill", "update", "--project", str(backup_linked), ok=False)
        assert (backup_linked / ".agents/skills/mew-website-engineer/SKILL.md").is_file()

        run(str(CLI), "init", "New Project", cwd=temp)
        assert (temp / "new-project" / ".agents/skills/mew-website-engineer/SKILL.md").is_file()

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            probe = str(target / "scripts" / "health-check.sh")
            base = "http://127.0.0.1:" + str(server.server_port)
            result = run(probe, base + "/?private-query=example")
            assert "private-query" not in result.stdout
            assert json.loads(result.stdout)["http_status"] == 200
            assert json.loads(run(str(CLI), "health", "check", base + "/cli").stdout)["http_status"] == 200
            assert json.loads(run(probe, base + "/fail").stdout)["http_status"] == 503
            assert json.loads(run(probe, base + "/redirect").stdout)["http_status"] == 302
            assert "/followed" not in Handler.hits
            run(probe, "http://user:secret@127.0.0.1/", ok=False)
            fake_bin = temp / "fake-bin"
            fake_bin.mkdir()
            fake_sleep = fake_bin / "sleep"
            fake_sleep.write_text("#!/bin/sh\nexit 0\n")
            fake_sleep.chmod(0o755)
            env = dict(os.environ, PATH=str(fake_bin) + os.pathsep + os.environ["PATH"])
            events = run(str(CLI), "health", "watch", base + "/fail", "--interval", "10", "--count", "3", env=env).stdout.splitlines()
            assert len(events) == 3 and all(json.loads(event)["result"]["http_status"] == 503 for event in events)
            run(str(CLI), "health", "watch", base, "--interval", "1", ok=False)
        finally:
            server.shutdown()
            server.server_close()
            thread.join()
        failure = run(probe, base + "/after-shutdown", ok=False)
        assert failure.returncode == 2 and json.loads(failure.stdout)["observation"] == "network_error"
        event = json.loads(run(str(CLI), "health", "watch", base + "/after-shutdown", "--count", "1").stdout)
        assert event["result"]["observation"] == "network_error"

    print("Portable skill integration tests passed.")


if __name__ == "__main__":
    main()
