#!/usr/bin/env python3
"""Read bounded local system metrics or an explicitly named systemd service."""
import argparse
import json
import os
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def memory_snapshot():
    fields = {}
    try:
        with open("/proc/meminfo", encoding="ascii") as stream:
            for line in stream:
                key, sep, value = line.partition(":")
                if sep and key in {"MemTotal", "MemAvailable"}:
                    match = re.fullmatch(r"\s*(\d+)\s+kB\s*", value)
                    if match:
                        fields[key] = int(match.group(1)) * 1024
    except OSError:
        pass
    if "MemTotal" not in fields or "MemAvailable" not in fields or fields["MemTotal"] <= 0:
        return {"state": "unavailable"}
    return {"state": "observed", "total_bytes": fields["MemTotal"], "available_bytes": fields["MemAvailable"]}


def system_observation(directory):
    path = Path(directory).expanduser().resolve()
    if not path.is_dir():
        raise ValueError("Choose an existing directory for disk observation.")
    try:
        disk = shutil.disk_usage(path)
        disk_data = {"state": "observed", "total_bytes": disk.total, "used_bytes": disk.used, "free_bytes": disk.free}
    except OSError:
        disk_data = {"state": "unavailable"}
    try:
        load = list(os.getloadavg())
    except (OSError, AttributeError):
        load = None
    return {
        "schema": "mew-system-observation/v1", "time": datetime.now(timezone.utc).isoformat(),
        "mode": "read_only", "disk": disk_data, "memory": memory_snapshot(),
        "load_average_1_5_15_minutes": load,
        "not_verified": ["website health", "application errors", "database connectivity", "service health", "traffic", "security"],
    }


def service_observation(unit):
    if not re.fullmatch(r"[-A-Za-z0-9_.@:]{1,180}\.service", unit) or unit.startswith("-"):
        raise ValueError("Use an explicit systemd service name such as nginx.service.")
    result = {"schema": "mew-service-observation/v1", "time": datetime.now(timezone.utc).isoformat(),
              "mode": "read_only", "service": unit, "observation": "unavailable", "reason": "systemctl_missing",
              "not_verified": ["website health", "database connectivity", "root cause"]}
    executable = shutil.which("systemctl")
    if executable is None:
        return result
    try:
        process = subprocess.run([executable, "show", "--no-pager", "--property=LoadState", "--property=ActiveState", "--property=SubState", "--", unit],
                                 stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=5, check=False)
    except subprocess.TimeoutExpired:
        result["reason"] = "systemctl_timeout"
        return result
    except OSError:
        result["reason"] = "systemctl_unavailable"
        return result
    if process.returncode != 0:
        result["reason"] = "systemctl_query_failed"
        return result
    fields = {}
    for line in process.stdout.splitlines():
        key, sep, value = line.partition("=")
        if sep and key in {"LoadState", "ActiveState", "SubState"} and re.fullmatch(r"[A-Za-z0-9_-]{1,60}", value):
            fields[key] = value
    if set(fields) != {"LoadState", "ActiveState", "SubState"}:
        result["reason"] = "incomplete_response"
        return result
    result.update({"observation": "observed", "load_state": fields["LoadState"], "active_state": fields["ActiveState"], "sub_state": fields["SubState"]})
    result.pop("reason", None)
    return result


def main():
    parser = argparse.ArgumentParser(description="One-shot read-only local observations. Never starts, stops or changes a service.")
    commands = parser.add_subparsers(dest="kind", required=True)
    system = commands.add_parser("system")
    system.add_argument("directory", help="existing directory on the filesystem to inspect")
    system.add_argument("--json", action="store_true")
    service = commands.add_parser("service")
    service.add_argument("unit", help="explicit local systemd service name")
    service.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        result = system_observation(args.directory) if args.kind == "system" else service_observation(args.unit)
    except ValueError as exc:
        parser.error(str(exc))
    if args.json:
        print(json.dumps(result, sort_keys=True))
    else:
        print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
