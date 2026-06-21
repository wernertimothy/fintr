# Fintr — Finance Tracker

A simple offline budget tracker for Android. Set a monthly limit per category, log
expenses, and watch a dashboard compare spending against your limits.

## Features

- User-managed categories, each with a monthly limit, color, and icon
- Add/edit/delete expenses, scoped per month
- Dashboard with animated progress bars (amber near the limit, red over budget) and a monthly total
- Local backup: export/import a JSON file inside the app's private folder

## Data

All data lives in a single JSON file (`fintr_data.json`) in the app's documents
directory. The storage layer sits behind a `Storage` interface
(`lib/data/storage.dart`), so swapping JSON for SQLite later is a one-file change.

## Run

```bash
flutter pub get
flutter run        # with an Android emulator or device connected
```

## Test

```bash
flutter analyze
flutter test
```

## Structure

- `lib/models/` — `Category`, `ExpenseItem`, `AppData` (JSON-serializable)
- `lib/data/` — `Storage` interface, `JsonFileStorage`, `FinanceRepository` (state + logic)
- `lib/screens/` — dashboard, add/edit item, categories, settings
- `lib/widgets/` — progress tile, month selector
