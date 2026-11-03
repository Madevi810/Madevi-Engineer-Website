#!/usr/bin/env python3
"""Test bounded system and service observations without controlling services."""
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLI = ROOT / "scripts" / "mew"


def run(*args, ok=True, env=None):
    result = subprocess.run([str(CLI), "observe", *args, "--json"], text=True, capture_output=True, env=env)
    assert (result.returncode == 0) == ok, (result.returncode, result.stdout, result.stderr)
    return json.loads(result.stdout) if ok else result


def main():
    with tempfile.TemporaryDirectory(prefix="mew-observe-") as temporary:
        temporary = Path(temporary)
        result = run("system", str(temporary))
        assert result["schema"] == "mew-system-observation/v1" and result["mode"] == "read_only"
        assert result["disk"]["state"] == "observed" and result["disk"]["total_bytes"] > 0
        assert result["memory"]["state"] in {"observed", "unavailable"}
        assert "website health" in result["not_verified"] and str(temporary) not in json.dumps(result)
        run("system", str(temporary / "missing"), ok=False)

        fake = temporary / "bin"
        fake.mkdir()
        executable = fake / "systemctl"
        executable.write_text("#!/bin/sh\nprintf '%s\\n' 'LoadState=loaded' 'ActiveState=active' 'SubState=running' 'Other=SECRET_NOT_ALLOWED'\n")
        executable.chmod(0o755)
        env = dict(os.environ, PATH=str(fake) + os.pathsep + os.environ["PATH"])
        result = run("service", "nginx.service", env=env)
        assert result["observation"] == "observed" and result["active_state"] == "active"
        assert "SECRET_NOT_ALLOWED" not in json.dumps(result)
        run("service", "nginx.service;touch-pwned", env=env, ok=False)
        run("service", "--no-pager", env=env, ok=False)
        executable.write_text("#!/bin/sh\nexit 1\n")
        result = run("service", "nginx.service", env=env)
        assert result["observation"] == "unavailable" and result["reason"] == "systemctl_query_failed"

    print("System observation integration tests passed.")


if __name__ == "__main__":
    main()
