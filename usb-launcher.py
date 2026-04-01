#!/usr/bin/env python3
"""Portable launcher for ShadowBroker.
Build as a single-file executable with PyInstaller:
  pyinstaller --onefile --name shadowbroker-usb usb-launcher.py
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import webbrowser
from pathlib import Path

FRONTEND_PORT = 3939
BACKEND_PORT = 8000


def find_compose_cmd() -> list[str]:
    docker = shutil.which("docker")
    if docker:
        try:
            subprocess.run([docker, "compose", "version"], check=True, capture_output=True)
            return [docker, "compose"]
        except Exception:
            pass

    docker_compose = shutil.which("docker-compose")
    if docker_compose:
        return [docker_compose]

    podman = shutil.which("podman")
    if podman:
        try:
            subprocess.run([podman, "compose", "version"], check=True, capture_output=True)
            return [podman, "compose"]
        except Exception:
            pass

    podman_compose = shutil.which("podman-compose")
    if podman_compose:
        return [podman_compose]

    return []


def run_compose(cmd: list[str], compose_file: Path, args: list[str]) -> int:
    proc = subprocess.run([*cmd, "-f", str(compose_file), *args])
    return proc.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="ShadowBroker USB launcher")
    parser.add_argument("--down", action="store_true", help="stop containers")
    parser.add_argument("--no-browser", action="store_true", help="do not auto-open browser")
    opts = parser.parse_args()

    root = Path(__file__).resolve().parent
    compose_file = root / "docker-compose.yml"
    if not compose_file.exists():
        print(f"[!] Missing {compose_file}")
        print("[!] Put this launcher next to the ShadowBroker project folder files.")
        return 1

    compose_cmd = find_compose_cmd()
    if not compose_cmd:
        print("[!] No compose runtime found. Install Docker Desktop, Docker Engine+Compose, or Podman.")
        return 1

    action = ["down"] if opts.down else ["up", "-d"]
    print(f"[*] Running: {' '.join(compose_cmd + action)}")
    code = run_compose(compose_cmd, compose_file, action)
    if code != 0:
        return code

    if not opts.down:
        url = f"http://localhost:{FRONTEND_PORT}"
        print("[*] ShadowBroker started")
        print(f"[*] Dashboard: {url}")
        print(f"[*] API: http://localhost:{BACKEND_PORT}")
        if not opts.no_browser:
            webbrowser.open(url)

    return 0


if __name__ == "__main__":
    sys.exit(main())
