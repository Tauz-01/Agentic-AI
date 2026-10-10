# RoamAgent (Flutter)

Multilingual AI travel concierge for **mock** intercity bus journeys. The Flutter app talks to an in-process backend that owns schedules, fares, ranking, disruption, and approval. The LLM-shaped layer only extracts intent and explains verified numbers.

## Run

Flutter SDK is required (`flutter` on PATH). From this folder:

```bash
flutter create . --project-name roam_agent --org com.roamagent
flutter pub get
flutter run
```

`flutter create .` adds Android / iOS / web / Windows platform files without overwriting `lib/`.

## Demo path

1. Speak (simulated STT) or paste the Vizag → Hyderabad request in English or Telugu.
2. Fill remaining required fields (travelers, berth, 45-minute transfer buffer). Search is blocked until they are set.
3. Pick a **feasible** top option (near-miss cards stay labeled as constraint misses).
4. Confirm **simulated** payment — no real card data.
5. The scripted 50-minute delay drops the transfer buffer from 55 to 5 minutes.
6. Recovery shows fare/ETA diffs. The active itinerary changes only after approve + demo confirmation.

All operational screens keep the **Demo · Simulated travel data** badge.
