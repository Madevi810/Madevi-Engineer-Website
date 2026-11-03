#!/usr/bin/env python3
"""Produce a bounded, read-only inventory of an explicitly selected web project."""
import argparse
import json
import os
import re
import stat
import sys
from pathlib import Path

MAX_ENTRIES = 5000
MAX_MANIFEST_BYTES = 256 * 1024
SKIP_DIRS = {".git", ".agents", ".hermes", ".venv", "venv", "node_modules", "vendor", "dist", "build", "coverage", "__pycache__"}
MARKERS = {
    "package.json": "node_manifest", "package-lock.json": "npm_lock", "pnpm-lock.yaml": "pnpm_lock",
    "yarn.lock": "yarn_lock", "bun.lockb": "bun_lock", "bun.lock": "bun_lock",
    "composer.json": "php_manifest", "composer.lock": "composer_lock", "requirements.txt": "python_requirements",
    "pyproject.toml": "python_manifest", "manage.py": "django_entry", "artisan": "laravel_entry",
    "Dockerfile": "dockerfile", "compose.yaml": "compose", "compose.yml": "compose",
    "docker-compose.yml": "compose", "docker-compose.yaml": "compose", "vercel.json": "vercel_config",
    "netlify.toml": "netlify_config", "nginx.conf": "nginx_config", "Caddyfile": "caddy_config",
    "index.html": "html_entry", "AGENTS.md": "agent_instructions", "FOUNDATION_MANIFEST.yaml": "mew_foundation",
}
LANGUAGES = {".js": "javascript", ".jsx": "javascript", ".ts": "typescript", ".tsx": "typescript", ".py": "python", ".php": "php", ".html": "html", ".css": "css", ".go": "go", ".rs": "rust"}
NODE_FRAMEWORKS = {"next": "next.js", "react": "react", "vue": "vue", "nuxt": "nuxt", "svelte": "svelte", "@sveltejs/kit": "sveltekit", "express": "express", "fastify": "fastify", "@nestjs/core": "nestjs", "astro": "astro"}
PHP_FRAMEWORKS = {"laravel/framework": "laravel", "symfony/framework-bundle": "symfony"}
PY_FRAMEWORKS = {"django": "django", "fastapi": "fastapi", "flask": "flask"}


def read_small_regular(path):
    """Read only a small regular manifest, never a symlink, FIFO, or oversized file."""
    try:
        info = path.lstat()
        if not stat.S_ISREG(info.st_mode) or info.st_size > MAX_MANIFEST_BYTES:
            return None
        flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_NONBLOCK", 0)
        fd = os.open(path, flags)
        with os.fdopen(fd, "rb") as stream:
            info = os.fstat(stream.fileno())
            if not stat.S_ISREG(info.st_mode) or info.st_size > MAX_MANIFEST_BYTES:
                return None
            data = stream.read(MAX_MANIFEST_BYTES + 1)
        if len(data) > MAX_MANIFEST_BYTES:
            return None
        return data.decode("utf-8")
    except (OSError, UnicodeError):
        return None


def inspect(root, depth_limit):
    markers = []
    frameworks = []
    languages = {}
    warnings = []
    stack = [(root, 0)]
    visited = 0
    truncated = False
    depth_limited = False
    skipped_symlinks = 0
    while stack:
        directory, depth = stack.pop()
        try:
            resolved = directory.resolve()
            if directory.is_symlink() or (resolved != root and root not in resolved.parents):
                warnings.append({"kind": "directory_outside_scope", "path": directory.relative_to(root).as_posix()})
                continue
            with os.scandir(directory) as entries:
                for entry in entries:
                    if visited >= MAX_ENTRIES:
                        truncated = True
                        break
                    visited += 1
                    name = entry.name
                    if entry.is_symlink():
                        skipped_symlinks += 1
                        continue
                    if entry.is_dir(follow_symlinks=False):
                        if name not in SKIP_DIRS and (not name.startswith(".") or name == ".github"):
                            if depth < depth_limit:
                                stack.append((Path(entry.path), depth + 1))
                            else:
                                depth_limited = True
                        continue
                    if not entry.is_file(follow_symlinks=False) or name.startswith(".env"):
                        continue
                    path = Path(entry.path)
                    rel = path.relative_to(root).as_posix()
                    if name in MARKERS:
                        markers.append({"kind": MARKERS[name], "path": rel})
                    language = LANGUAGES.get(path.suffix.lower())
                    if language:
                        languages[language] = languages.get(language, 0) + 1
                    if name not in {"package.json", "composer.json", "requirements.txt"}:
                        continue
                    content = read_small_regular(path)
                    if content is None:
                        warnings.append({"kind": "manifest_unreadable_or_too_large", "path": rel})
                        continue
                    if name in {"package.json", "composer.json"}:
                        try:
                            data = json.loads(content)
                        except (json.JSONDecodeError, ValueError):
                            warnings.append({"kind": "manifest_invalid", "path": rel})
                            continue
                        if not isinstance(data, dict):
                            warnings.append({"kind": "manifest_invalid", "path": rel})
                            continue
                        sections = ("dependencies", "devDependencies", "peerDependencies") if name == "package.json" else ("require", "require-dev")
                        known = NODE_FRAMEWORKS if name == "package.json" else PHP_FRAMEWORKS
                        for section in sections:
                            deps = data.get(section, {})
                            if isinstance(deps, dict):
                                for key, label in known.items():
                                    if key in deps:
                                        frameworks.append({"name": label, "evidence": rel})
                    else:
                        for line in content.splitlines():
                            match = re.match(r"^\s*([a-zA-Z0-9_.-]+)", line)
                            if match:
                                label = PY_FRAMEWORKS.get(match.group(1).lower().replace("_", "-"))
                                if label:
                                    frameworks.append({"name": label, "evidence": rel})
        except OSError:
            warnings.append({"kind": "directory_unreadable", "path": directory.relative_to(root).as_posix()})
        if truncated:
            break
    markers.sort(key=lambda item: (item["path"], item["kind"]))
    frameworks = [dict(name=name, evidence=evidence) for name, evidence in sorted({(x["name"], x["evidence"]) for x in frameworks})]
    warnings.sort(key=lambda item: (item["path"], item["kind"]))
    return {
        "schema": "mew-project-inspection/v1", "mode": "read_only", "project": root.name,
        "scope": {"max_depth": depth_limit, "max_entries": MAX_ENTRIES, "max_manifest_bytes": MAX_MANIFEST_BYTES, "visited_entries": visited, "truncated": truncated, "depth_limited": depth_limited, "skipped_symlinks": skipped_symlinks},
        "markers": markers, "framework_evidence": frameworks, "source_file_counts": dict(sorted(languages.items())),
        "warnings": warnings,
        "not_verified": ["running services", "network or traffic", "database connection", "credentials", "dependency compatibility", "project security", "application behavior"],
    }


def main():
    parser = argparse.ArgumentParser(description="Read-only, bounded project inventory; does not execute project code.")
    parser.add_argument("directory", help="project directory the developer authorized")
    parser.add_argument("--json", action="store_true", help="emit a machine-readable report")
    parser.add_argument("--max-depth", type=int, default=3, choices=range(0, 9), metavar="0..8")
    args = parser.parse_args()
    root = Path(args.directory).expanduser().resolve()
    if not root.is_dir():
        parser.error("project directory does not exist or is not a directory")
    result = inspect(root, args.max_depth)
    if args.json:
        print(json.dumps(result, ensure_ascii=True, sort_keys=True))
    else:
        print("MEW project inventory (read-only):", result["project"])
        print("Markers:")
        for item in result["markers"]:
            print("  -", item["kind"], "[" + item["path"] + "]")
        print("Framework evidence:")
        for item in result["framework_evidence"]:
            print("  -", item["name"], "[" + item["evidence"] + "]")
        print("Source-file counts:", json.dumps(result["source_file_counts"], sort_keys=True))
        print("Warnings:", len(result["warnings"]), "Truncated:", str(result["scope"]["truncated"]).lower(), "Depth limited:", str(result["scope"]["depth_limited"]).lower())
        print("Not verified:", ", ".join(result["not_verified"]))
        print("Evidence is indicative; verify versions, running services and compatibility separately.")


if __name__ == "__main__":
    main()
