# game_dart

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android AAB CI / Play Store Upload

This repository includes a GitHub Actions workflow at
[.github/workflows/android-aab.yml](.github/workflows/android-aab.yml).

What it does:
- Builds a signed release AAB.
- Uploads the AAB as a GitHub artifact.
- Publishes GitHub Release on tag pushes (`v*`).
- Optionally uploads to Google Play when manually triggered.

Required repository secrets:
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAYSTORE_SERVICE_ACCOUNT_JSON` (only needed for Play upload)

Manual run for Play upload:
1. Open GitHub Actions -> `Android AAB Build` -> `Run workflow`.
2. Set `upload_to_play = true`.
3. Select `track` (`internal`, `alpha`, `beta`, or `production`).
4. Select `release_status` (`completed`, `draft`, `inProgress`, `halted`).

Google Play requirement:
- Service account in Google Cloud with Play Console access for package
	`com.ademiralay.game_dart`.
