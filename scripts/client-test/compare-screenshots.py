#!/usr/bin/env python3
"""Compares Redemption client screenshots with the legacy client's.

    compare-screenshots.py <legacy dir> <redemption dir> <report dir> [--tolerance N] [--max-diff P]

Each PNG in the legacy dir is compared with the PNG of the same name in the redemption
dir. A pixel differs when any channel differs by more than --tolerance (default 24).
A screenshot passes when at most --max-diff percent of its pixels differ (default 1.0).
Writes report.md, report.json and a diff image per screenshot (differing pixels in red).
Exits 1 if any screenshot fails or is missing.
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image


def compare(legacy_path, redemption_path, diff_path, tolerance):
    a = np.asarray(Image.open(legacy_path).convert("RGB"), dtype=np.int16)
    b = np.asarray(Image.open(redemption_path).convert("RGB"), dtype=np.int16)
    if a.shape != b.shape:
        return {"error": f"size {a.shape[1]}x{a.shape[0]} vs {b.shape[1]}x{b.shape[0]}"}
    delta = np.abs(a - b).max(axis=2)
    mask = delta > tolerance
    out = (a * 0.35).astype(np.uint8)
    out[mask] = (255, 0, 0)
    Image.fromarray(out).save(diff_path)
    return {
        "diff_percent": round(100.0 * float(mask.sum()) / mask.size, 3),
        "mean_delta": round(float(delta.mean()), 3),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("legacy")
    parser.add_argument("redemption")
    parser.add_argument("report")
    parser.add_argument("--tolerance", type=int, default=24)
    parser.add_argument("--max-diff", type=float, default=1.0)
    args = parser.parse_args()

    legacy, redemption, report = Path(args.legacy), Path(args.redemption), Path(args.report)
    report.mkdir(parents=True, exist_ok=True)
    results = {}
    for shot in sorted(legacy.glob("*.png")):
        other = redemption / shot.name
        if not other.exists():
            results[shot.stem] = {"error": "missing in the Redemption run"}
        else:
            results[shot.stem] = compare(shot, other, report / f"{shot.stem}-diff.png", args.tolerance)
        r = results[shot.stem]
        r["pass"] = bool("error" not in r and r["diff_percent"] <= args.max_diff)
    for shot in sorted(redemption.glob("*.png")):
        if not (legacy / shot.name).exists():
            results[shot.stem] = {"error": "missing in the legacy run", "pass": False}

    lines = [f"# Screenshot parity (tolerance {args.tolerance}, max {args.max_diff}% of pixels)", "",
             "| Screenshot | Result | Differing pixels | Mean delta |", "| --- | --- | --- | --- |"]
    for name, r in sorted(results.items()):
        status = "pass" if r["pass"] else "FAIL"
        if "error" in r:
            lines.append(f"| {name} | {status} | {r['error']} | |")
        else:
            lines.append(f"| {name} | {status} | {r['diff_percent']}% | {r['mean_delta']} |")
    (report / "report.md").write_text("\n".join(lines) + "\n")
    (report / "report.json").write_text(json.dumps(results, indent=2) + "\n")
    print("\n".join(lines))

    if not results:
        print("FAIL: no screenshots to compare")
        return 1
    return 0 if all(r["pass"] for r in results.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
