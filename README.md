# Fishing Assistant

A fly-fishing assistant app for Android & iOS, built with Flutter. It combines
the data sources anglers normally check separately — water conditions, moon &
solunar periods, weather, and insect hatches — into a single "should I fish
today, and what flies should I bring?" view.

This is the **Phase 1 MVP** described in the project guideline.

## Features

- **Home dashboard** — for the selected river: water level, flow and temperature
  with a comparison to seasonal normals, current weather, moon phase, today's
  likely hatches, recommended flies, and an overall **0–10 fishing score**.
- **River selection** — search and favorite rivers. Seeded with San, Dunajec,
  Wisła and Bóbr.
- **Hatch calendar** — month-by-month likely hatches (species, stage,
  probability) and suggested flies for each river.
- **Moon & solunar tab** — phase, illumination, moon age, next full/new moon,
  moonrise/moonset, major/minor solunar feeding periods, and a monthly moon
  calendar. All computed on-device.
- **Fishing log** — record trips (river, date, weather, water level, fly, fish
  species/count/size, notes). Lunar context is captured automatically. Stored
  locally on the device.

## Fishing score

A simple rule-based score (from the guideline):

| Factor                          | Points |
| ------------------------------- | ------ |
| Water level / flow near normal  | +3     |
| Water temperature ideal (8–16°C)| +2     |
| Moon phase favorable            | +2     |
| Active hatch today              | +3     |

`0–3 Poor · 4–6 Fair · 7–8 Good · 9–10 Excellent`

## Data sources

- **Weather** — [Open-Meteo](https://open-meteo.com/) (free, no API key).
- **Moon** — computed on-device (Paul Schlyter's low-precision lunar theory);
  no external service.
- **Hatches** — curated static regional chart.
- **Water levels** — currently deterministic, realistic placeholder readings
  derived from each river's seasonal baseline. Live hydrological gauge
  integration (e.g. Poland's IMGW) is planned for a later phase.

## Project structure

```
lib/
├── main.dart            # App entry + bottom navigation
├── theme.dart
├── models/              # river, water_reading, hatch, fishing_log, moon_info, weather
├── services/            # moon, weather, water, hatch, score, log, river
├── providers/           # AppState (ChangeNotifier)
├── screens/             # home, river, hatch, moon, log, add_log
├── widgets/             # shared UI (SectionCard, MetricRow)
└── utils/               # formatting helpers
```

## Running

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK (3.44+). Targets Android and iOS.

## Roadmap (later phases)

- Supabase backend (accounts, cloud sync, photo storage)
- Live water gauge APIs (IMGW / national hydrological agencies)
- Mapbox maps & GPS river finder
- User-submitted hatch observations → prediction model
- AI-generated fishing recommendations
