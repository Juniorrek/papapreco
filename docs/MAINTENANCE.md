# PapaPreco: maintenance notes

Things that are not broken, but will need attention. Nothing here is required to
build or run the app. See [../README.md](../README.md) for that.

Planned work with a phase and a rationale lives in [ROADMAP.md](ROADMAP.md).
This file is the watch-list: dependencies that are drifting, and upgrades
deliberately not taken yet.

## Toolchain

The Android toolchain was bumped in July 2026 to **Gradle 8.14 / AGP 8.11.1 /
Kotlin 2.2.20**, so the project builds against current Flutter SDKs. Those three
are pinned, in `android/gradle/wrapper/gradle-wrapper.properties` and
`android/settings.gradle` respectively.

The **Flutter SDK version is not pinned by anything**, only documented
(3.44.1 / Dart 3.12.1, in the README). That matters more than it looks:
`android/app/build.gradle` derives `compileSdk`, `minSdk`, `targetSdk` and
`ndkVersion` from `flutter.*`, so changing Flutter changes what the APK is
compiled and targeted against with no diff in any tracked file. Making that a
literal is a roadmap item.

## Migrate to Flutter's Built-in Kotlin

`flutter run` and `flutter build` both warn that applying the Kotlin Gradle
Plugin directly, as `android/app/build.gradle` and the `mobile_scanner` plugin
do, **will stop working in a future Flutter release**.

This cannot be finished yet: it is blocked on `mobile_scanner` (and any other
plugin that applies KGP itself) shipping a version that supports Built-in
Kotlin. Check its changelog before attempting.

[Migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)

Worth being explicit about the interaction with the pinned Flutter version: the
README tells you to stay on 3.44.1, which is what keeps this warning a warning.
The pin defers this problem rather than solving it, so the two move together:
whenever Flutter is bumped, this is the thing most likely to break.

## `flutter_compass`

A transitive dependency, via `flutter_map_location_marker` →
`location_picker_flutter_map`, and lightly maintained. If the location-picker or
compass behaviour starts misbehaving, check whether a newer release exists or
whether it needs swapping for an alternative.

## Pending major upgrades

These are held at their locked minor/patch versions on purpose. Major bumps
usually carry breaking API changes that need dedicated testing, and there is no
test suite covering these paths yet.

- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`
- `geolocator`
- `google_sign_in`
- `flutter_map`
- `location_picker_flutter_map`
- `mobile_scanner` (7.x)

`flutter pub outdated` shows the current gaps. Note that `pubspec.lock` is
committed and `flutter pub get` honours it. Only `flutter pub upgrade` moves
these, and the constraints in `pubspec.yaml` are carets, so it can move them a
long way at once.
