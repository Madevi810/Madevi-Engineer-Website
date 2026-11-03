#!/usr/bin/env python3
"""Integration tests for MEW's portable skill and one-shot HTTP probe."""
import json
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


def run(*args, cwd=None, ok=True):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=False)
    assert (result.returncode == 0) == ok, (args, result.returncode, result.stdout, result.stderr)
    return result


def main():
    skill = (PACKAGE / "SKILL.md").read_text()
    assert skill.startswith("---\nname: mew-website-engineer\ndescription: ")
    for path in ("references/engineering.md", "references/live-operations.md", "scripts/health-check.sh"):
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
        assert (project / "AGENTS.md").read_text() == "Existing project rules\n"
        (target / "keep.txt").write_text("keep")
        run(str(CLI), "skill", "install", "--project", str(project), ok=False)
        assert (target / "keep.txt").read_text() == "keep"

        linked = temp / "linked-project"
        linked.mkdir()
        (linked / ".agents").symlink_to(project / ".agents", target_is_directory=True)
        run(str(CLI), "skill", "install", "--project", str(linked), ok=False)

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
        finally:
            server.shutdown()
            server.server_close()
            thread.join()
        failure = run(probe, base + "/after-shutdown", ok=False)
        assert failure.returncode == 2 and json.loads(failure.stdout)["observation"] == "network_error"

    print("Portable skill integration tests passed.")


if __name__ == "__main__":
    main()
