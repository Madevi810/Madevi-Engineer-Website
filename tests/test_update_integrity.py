#!/usr/bin/env python3
"""Exercise update failures using isolated local Git repositories and tags."""
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(*args, cwd=None, env=None, ok=True):
    result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
    assert (result.returncode == 0) == ok, (args, result.returncode, result.stdout, result.stderr)
    return result


def git(cwd, *args, ok=True):
    return run("git", "-c", "core.hooksPath=/dev/null", *args, cwd=cwd, ok=ok)


def main():
    with tempfile.TemporaryDirectory(prefix="mew-update-integrity-") as temporary:
        temp = Path(temporary)
        remote, source = temp / "remote.git", temp / "source"
        git(temp, "init", "--bare", str(remote))
        git(temp, "init", "-b", "main", str(source))
        git(source, "config", "user.name", "MEW test")
        git(source, "config", "user.email", "mew-test@example.invalid")
        (source / "scripts").mkdir()
        shutil.copy(ROOT / "scripts/update.sh", source / "scripts/update.sh")
        fixture_mew = source / "scripts/mew"
        fixture_mew.write_text("#!/bin/sh\nexit 0\n")
        fixture_mew.chmod(0o755)
        checker = source / "scripts/check-repository.sh"
        checker.write_text("#!/bin/sh\nexit 0\n")
        checker.chmod(0o755)
        (source / "VERSION").write_text("2.1.0\n")
        (source / ".gitignore").write_text("cache.tmp\n")
        (source / "README.md").write_text("fixture\n")
        git(source, "add", ".")
        git(source, "commit", "-m", "stable fixture")
        git(source, "tag", "v2.1.0")
        (source / "VERSION").write_text("2.1.1\n")
        checker.write_text("#!/bin/sh\nexit 1\n")
        (source / "cache.tmp").write_text("tracked by update\n")
        git(source, "add", "VERSION", "scripts/check-repository.sh")
        git(source, "add", "-f", "cache.tmp")
        git(source, "commit", "-m", "failing fixture")
        git(source, "tag", "v2.1.1")
        git(source, "tag", "2.1.9")
        git(source, "remote", "add", "origin", str(remote))
        git(source, "push", "origin", "main", "--tags")

        env = dict(os.environ, MEW_REPO_URL=str(remote))

        def clone(name):
            target = temp / name
            run("git", "clone", "--branch", "v2.1.0", str(remote), str(target))
            return target

        failed = clone("failed")
        before = git(failed, "rev-parse", "HEAD").stdout.strip()
        check = run("bash", str(failed / "scripts/update.sh"), "--check", cwd=failed, env=env)
        assert "Target:  2.1.1" in check.stdout
        result = run("bash", str(failed / "scripts/update.sh"), cwd=failed, env=env, ok=False)
        assert "restoring the previous installation" in result.stderr
        assert git(failed, "rev-parse", "HEAD").stdout.strip() == before
        assert (failed / "VERSION").read_text().strip() == "2.1.0"

        staged = clone("staged")
        (staged / "README.md").write_text("developer modification\n")
        git(staged, "add", "README.md")
        result = run("bash", str(staged / "scripts/update.sh"), cwd=staged, env=env, ok=False)
        assert "staged" in result.stderr and (staged / "README.md").read_text() == "developer modification\n"

        untracked = clone("untracked")
        (untracked / "notes.txt").write_text("keep\n")
        result = run("bash", str(untracked / "scripts/update.sh"), cwd=untracked, env=env, ok=False)
        assert "untracked" in result.stderr and (untracked / "notes.txt").read_text() == "keep\n"

        no_match = clone("no-match")
        (no_match / "VERSION").write_text("2.2.0\n")
        result = run("bash", str(no_match / "scripts/update.sh"), "--check", cwd=no_match, env=env)
        assert "No compatible stable update" in result.stdout
        bad_env = dict(env, MEW_REPO_URL=str(temp / "missing-remote"))
        result = run("bash", str(no_match / "scripts/update.sh"), "--check", cwd=no_match, env=bad_env, ok=False)
        assert "Unable to query stable tags" in result.stderr

        ignored = clone("ignored")
        (ignored / "cache.tmp").write_text("user ignored data\n")
        run("bash", str(ignored / "scripts/update.sh"), cwd=ignored, env=env, ok=False)
        assert (ignored / "cache.tmp").read_text() == "user ignored data\n"
        assert (ignored / "VERSION").read_text().strip() == "2.1.0"

        (source / "VERSION").write_text("2.1.2\n")
        checker.write_text("#!/bin/sh\nexit 0\n")
        git(source, "add", "VERSION", "scripts/check-repository.sh")
        git(source, "commit", "-m", "valid fixture")
        git(source, "tag", "v2.1.2")
        git(source, "push", "origin", "main", "--tags")
        successful = clone("successful")
        run("bash", str(successful / "scripts/update.sh"), cwd=successful, env=env)
        assert (successful / "VERSION").read_text().strip() == "2.1.2"

        install_env = dict(env, MEW_INSTALL_DIR=str(temp / "installed"), MEW_BIN_DIR=str(temp / "bin"), MEW_CONFIG_DIR=str(temp / "config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=install_env)
        assert "MEW v2.1.2 installed" in result.stdout
        assert (temp / "installed/VERSION").read_text().strip() == "2.1.2"
        (temp / "installed/user-note.txt").write_text("keep prior data")
        run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=install_env)
        backups = list(temp.glob(".mew-backup.*/previous/user-note.txt"))
        assert len(backups) == 1 and backups[0].read_text() == "keep prior data"

        collision = temp / "collision-bin"
        collision.mkdir()
        (collision / "mew").write_text("unrelated command")
        collision_env = dict(install_env, MEW_INSTALL_DIR=str(temp / "collision-install"), MEW_BIN_DIR=str(collision), MEW_CONFIG_DIR=str(temp / "collision-config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=collision_env, ok=False)
        assert "Refusing to replace an existing mew command" in result.stderr
        assert (collision / "mew").read_text() == "unrelated command" and not (temp / "collision-install").exists()

        old = temp / "old-install"
        (old / "scripts").mkdir(parents=True)
        (old / "VERSION").write_text("old version")
        (old / "scripts/mew").write_text("old command")
        fake_bin = temp / "failure-bin"
        fake_bin.mkdir()
        (fake_bin / "ln").write_text("#!/bin/sh\nexit 1\n")
        (fake_bin / "ln").chmod(0o755)
        failure_env = dict(install_env, PATH=str(fake_bin) + os.pathsep + os.environ["PATH"], MEW_INSTALL_DIR=str(old), MEW_BIN_DIR=str(temp / "old-bin"), MEW_CONFIG_DIR=str(temp / "old-config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=failure_env, ok=False)
        assert "Could not create the mew command" in result.stderr
        assert (old / "VERSION").read_text() == "old version" and (old / "scripts/mew").read_text() == "old command"

        config_old = temp / "config-failure-install"
        (config_old / "scripts").mkdir(parents=True)
        (config_old / "VERSION").write_text("old version")
        (config_old / "scripts/mew").write_text("old command")
        mv_bin = temp / "mv-failure-bin"
        mv_bin.mkdir()
        (mv_bin / "mv").write_text("#!/bin/sh\ncase \"$1\" in */.install.env.*) exit 1 ;; esac\nexec \"$MEW_REAL_MV\" \"$@\"\n")
        (mv_bin / "mv").chmod(0o755)
        config_env = dict(install_env, PATH=str(mv_bin) + os.pathsep + os.environ["PATH"], MEW_REAL_MV=shutil.which("mv"), MEW_INSTALL_DIR=str(config_old), MEW_BIN_DIR=str(temp / "config-failure-bin"), MEW_CONFIG_DIR=str(temp / "config-failure-config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=config_env, ok=False)
        assert "Could not save installer configuration" in result.stderr
        assert (config_old / "VERSION").read_text() == "old version" and not (temp / "config-failure-bin/mew").exists()

        relative_env = dict(install_env, MEW_INSTALL_DIR="relative-install", MEW_BIN_DIR="relative-bin", MEW_CONFIG_DIR="relative-config")
        run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=relative_env)
        assert (temp / "relative-bin/mew").is_symlink() and (temp / "relative-bin/mew").resolve().is_file()

        unsafe = temp / "unrecognized"
        unsafe.mkdir()
        (unsafe / "valuable.txt").write_text("keep")
        unsafe_env = dict(install_env, MEW_INSTALL_DIR=str(unsafe), MEW_BIN_DIR=str(temp / "unsafe-bin"), MEW_CONFIG_DIR=str(temp / "unsafe-config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=unsafe_env, ok=False)
        assert "unrecognized installation directory" in result.stderr and (unsafe / "valuable.txt").read_text() == "keep"

        overlap = temp / "overlap"
        (overlap / "bin").mkdir(parents=True)
        overlap_env = dict(install_env, MEW_INSTALL_DIR=str(overlap), MEW_BIN_DIR=str(overlap / "bin"), MEW_CONFIG_DIR=str(temp / "overlap-config"))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=overlap_env, ok=False)
        assert "directories must not overlap" in result.stderr and overlap.is_dir()
        empty = temp / "empty.git"
        git(temp, "init", "--bare", str(empty))
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=dict(install_env, MEW_REPO_URL=str(empty)), ok=False)
        assert "No stable MEW release tag" in result.stderr
        result = run("bash", str(ROOT / "scripts/install.sh"), cwd=temp, env=dict(install_env, MEW_REPO_URL=str(temp / "missing-remote")), ok=False)
        assert "Unable to query stable tags" in result.stderr
        result = run("bash", str(ROOT / "scripts/install.sh"), "--version", "bad-tag", cwd=temp, env=install_env, ok=False)
        assert "Version must be a stable tag" in result.stderr
    print("Update integrity tests passed.")


if __name__ == "__main__":
    main()
