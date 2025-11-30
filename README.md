# SwipePlan

SwipePlan is a Flutter + Supabase experiment for coordinating shared watch plans with swipe-style interactions. The UI is built with Flutter's Material 3 widgets and uses Supabase for persistence with either Supabase Auth or Clerk providing the authentication layer.

## Prerequisites

- Flutter 3.22+ with the associated Android/iOS tooling installed
- A configured Supabase project – copy `.env.example` to `.env` and populate `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Choose your auth provider:
  - `AUTH_PROVIDER=supabase` to keep the built-in email/password + Supabase OAuth flow (also set `SUPABASE_REDIRECT_URL` if you enable Google sign-in).
  - `AUTH_PROVIDER=clerk` to use Clerk’s hosted UI – set `CLERK_PUBLISHABLE_KEY` and configure the same deep link scheme inside the Clerk dashboard plus your Flutter platforms.
- A connected simulator/emulator or physical device

## Quickstart

```bash
git clone <repo-url>
cd SwipePlan
make setup          # installs Dart/Flutter dependencies
make run            # launches the app on the active device/emulator
```

If you prefer to call Flutter directly, run `flutter pub get` followed by `flutter run`.

## Environment Configuration

Create a `.env` file (see `.env.example`) that defines:

| Key | Description |
| --- | --- |
| `SUPABASE_URL` | Your Supabase project URL. |
| `SUPABASE_ANON_KEY` | The public anon key from the Supabase dashboard. |
| `SUPABASE_REDIRECT_URL` (optional) | Deep link/redirect URI Supabase should use when completing OAuth flows (e.g., `com.myapp://auth-callback`). Required when `AUTH_PROVIDER=supabase` and you want Google sign-in. |
| `AUTH_PROVIDER` | Either `supabase` (default, email/password only) or `clerk` (hosted UI + OAuth through Clerk). |
| `CLERK_PUBLISHABLE_KEY` | Required when `AUTH_PROVIDER=clerk`; copy it from the Clerk dashboard. |

When using OAuth in Supabase or when integrating Clerk you must register the same scheme/host pair in your Android `AndroidManifest.xml` and iOS `Runner/Info.plist` so callbacks can reopen the app.

## Makefile Tasks

| Command | Description |
| --- | --- |
| `make setup` | Install dependencies (`flutter pub get`). |
| `make run [DEVICE=id]` | Launch the app on the active or specified device (`flutter run -d id`). |
| `make analyze` | Static analysis via `flutter analyze`. |
| `make format` | Format the Dart sources under `lib/`. |
| `make test` | Execute `flutter test`. |
| `make build-apk` | Produce a release APK (Android). |
| `make build-ios` | Produce an iOS archive (requires macOS + Xcode). |
| `make clean` | Remove Flutter build artifacts. |

Override `DEVICE` for simultaneous devices, e.g. `make run DEVICE=chrome`.

## Project Structure

- `lib/main.dart` – application entry point that wires up Supabase, authentication gate, and providers.
- `lib/login_screen.dart` – email/password login UI for Supabase auth.
- `lib/home_screen.dart` – post-login shell that switches between tabs.
- `lib/watch_tab.dart` – watchlist tab logic and widgets driven by providers.

## Troubleshooting

- **Supabase credentials**: Make sure `.env` contains the correct project details and that the file is bundled via `flutter pub get` (listed under `flutter.assets` in `pubspec.yaml`), otherwise initialization fails at startup.
- **Auth provider mismatch**: If you select `AUTH_PROVIDER=clerk` without `CLERK_PUBLISHABLE_KEY` (or without configuring deep links in Clerk + Flutter), the login screen will remain blank.
- **OAuth redirect**: If Google login or Clerk OAuth flows stall in a browser, double-check that the redirect URL in Supabase/Clerk matches your configured deep link and that the scheme is registered on each platform.
- **Google sign-in**: Supabase's built-in flow now only supports email/password. To offer Google or other OAuth buttons, switch to `AUTH_PROVIDER=clerk` so Clerk handles the third-party flow end-to-end.
- **Group membership**: Swiping requires an active group because swipes are stored per group. Use the Groups screen to create or join a group before visiting the Watch tab.
- **Device discovery**: Verify `flutter devices` lists your emulator/phone; pass its ID through `DEVICE`.
- **Dependency drift**: Run `make clean setup` if you bump Flutter versions or change packages.
