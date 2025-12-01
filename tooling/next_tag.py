#!/usr/bin/env python3
"""Derive the next semantic tag for the project.

Falls back to `v0.1.0` when no matching tag is found or parsing fails.
"""
from __future__ import annotations

import os
import sys


def default(prefix: str) -> str:
    return f"{prefix}0.1.0"


def main() -> int:
    prefix = os.environ.get("TAG_PREFIX", "v")
    latest = os.environ.get("LATEST_TAG", "").strip()
    if not latest:
        print(default(prefix))
        return 0

    core = latest[len(prefix):] if latest.startswith(prefix) else latest
    parts = core.split(".")
    try:
        major = int(parts[0]) if parts and parts[0] else 0
        minor = int(parts[1]) if len(parts) > 1 and parts[1] else 0
        patch = int(parts[2]) if len(parts) > 2 and parts[2] else 0
    except ValueError:
        print(default(prefix))
        return 0

    patch += 1
    print(f"{prefix}{major}.{minor}.{patch}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
