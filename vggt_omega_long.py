#!/usr/bin/env python3
"""Convenience entry point for VGGT-Omega-Long.

The implementation lives in `vggt_long.py` so the original VGGT-Long command
line interface stays intact.
"""

from pathlib import Path
import runpy


if __name__ == "__main__":
    runpy.run_path(str(Path(__file__).with_name("vggt_long.py")), run_name="__main__")
