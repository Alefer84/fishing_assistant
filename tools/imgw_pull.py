#!/usr/bin/env python3
"""Pull live water readings for the Dunajec IMGW gauges and append them to a CSV
archive.

Uses only the Python standard library (no third-party deps) so it runs anywhere.
Data source: IMGW public API (https://danepubliczne.imgw.pl), free, no API key.

Usage:
    python3 tools/imgw_pull.py            # append to data/imgw_history.csv
    python3 tools/imgw_pull.py --out PATH # custom output file
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import urllib.request
from datetime import datetime, timezone

API = "https://danepubliczne.imgw.pl/api/data/hydro/id/{station_id}"

# Dunajec gauges surfaced in the app.
STATIONS = [
    {"id": "149200160", "name": "Krościenko"},
    {"id": "149200140", "name": "Sromowce Wyżne"},
    {"id": "149200190", "name": "Gołkowice"},
]

FIELDS = [
    "pulled_at_utc",
    "station_id",
    "station_name",
    "river",
    "level_cm",
    "level_measured_at",
    "flow_cms",
    "flow_measured_at",
    "temp_c",
    "temp_measured_at",
]


def fetch(station_id: str) -> dict:
    url = API.format(station_id=station_id)
    req = urllib.request.Request(url, headers={"User-Agent": "fishing-assistant"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        payload = json.loads(resp.read().decode("utf-8"))
    if isinstance(payload, list):
        if not payload:
            raise ValueError(f"No data for station {station_id}")
        return payload[0]
    return payload


def row_for(station: dict, pulled_at: str) -> dict:
    data = fetch(station["id"])
    return {
        "pulled_at_utc": pulled_at,
        "station_id": station["id"],
        "station_name": station["name"],
        "river": data.get("rzeka", ""),
        "level_cm": data.get("stan_wody"),
        "level_measured_at": data.get("stan_wody_data_pomiaru"),
        "flow_cms": data.get("przeplyw"),
        "flow_measured_at": data.get("przeplyw_data"),
        "temp_c": data.get("temperatura_wody"),
        "temp_measured_at": data.get("temperatura_wody_data_pomiaru"),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Append live IMGW readings to a CSV archive.")
    default_out = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "data",
        "imgw_history.csv",
    )
    parser.add_argument("--out", default=default_out, help="CSV output path")
    args = parser.parse_args()

    pulled_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    rows = []
    for station in STATIONS:
        try:
            rows.append(row_for(station, pulled_at))
            print(f"OK   {station['name']} ({station['id']})")
        except Exception as exc:  # noqa: BLE001 - log and continue with others
            print(f"FAIL {station['name']} ({station['id']}): {exc}", file=sys.stderr)

    if not rows:
        print("No readings fetched; nothing written.", file=sys.stderr)
        return 1

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    is_new = not os.path.exists(args.out) or os.path.getsize(args.out) == 0
    with open(args.out, "a", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=FIELDS)
        if is_new:
            writer.writeheader()
        writer.writerows(rows)

    print(f"Appended {len(rows)} row(s) to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
