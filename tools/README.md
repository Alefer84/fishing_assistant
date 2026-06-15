# Tools

## `imgw_pull.py`

Dependency-free Python script that pulls live water readings for the Dunajec
IMGW gauges (Krościenko `149200160`, Sromowce Wyżne `149200140`,
Gołkowice `149200190`) and appends them to `data/imgw_history.csv`.

```bash
python3 tools/imgw_pull.py
```

Data source: IMGW public API (https://danepubliczne.imgw.pl), free, no API key.

A scheduled Devin session runs this every 2 hours, appends the latest readings,
and pushes the updated `data/imgw_history.csv` to the repo, giving an always-on
archive even while the app is closed. The app itself fetches the same API live
and auto-refreshes every 2 hours while open.
