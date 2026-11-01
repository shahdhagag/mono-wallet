# Mono Wallet

Mono Wallet is a Flutter wallet and spending tracker backed by Supabase. It
lets an authenticated user manage wallet accounts, record income and expenses,
review transaction history, inspect statistics, and optionally turn an Arabic
or English voice transcript into editable transactions before saving.

## Status

The repository is a working Flutter client with Supabase auth and data access.
The checked-in project contains no Supabase migrations or RLS policies, so the
database contract and provider setup must be verified in the Supabase project
before production release. See [the security proposal](docs/supabase_security_proposal.md).

Verified locally: `flutter analyze` has no errors, and the complete test suite
passes without real Supabase or Gemini credentials. Android, iOS, and OAuth
provider configuration are not claimed as verified by these checks.

## Implemented Features

- Email/password sign-in, registration, email confirmation messaging, logout,
	password reset, and password update flows.
- Google and Apple OAuth entry points. Provider dashboard and platform setup
	remain required.
- Supabase-backed profiles, wallet accounts, transactions, and bills.
- Income and expense entry, transaction deletion, account selection, loading,
	empty, and error states.
- Statistics aggregation from loaded transactions by type and category.
- Arabic-Indic and Persian digit normalization for voice parsing.
- Speech recognition followed by Gemini parsing, editable confirmation, and
	batch save.

## Screenshots

Screenshots are not included yet. Add reviewed screenshots here before the
GitHub release.

## Tech Stack And Structure

- Flutter and Dart
- Supabase Auth and Postgres via `supabase_flutter`
- BLoC/Cubit state management
- `go_router` navigation and GetIt service registration
- `speech_to_text` and Gemini parsing for voice entry

Feature code is organized under `lib/features/<feature>` with presentation,
domain, and data folders where those layers exist. Shared routing, theme,
errors, networking, and helpers live under `lib/core`.

## Prerequisites

- Flutter SDK compatible with Dart `>=3.11.4 <4.0.0`
- Xcode for iOS development, Android Studio/SDK for Android development
- A Supabase project with the tables, RPC functions, foreign keys, and RLS
	policies required by the client

## Configuration

The Supabase URL and publishable key are currently configured in
`lib/main.dart`. The publishable key is client-safe only when RLS protects
every exposed table. Never place a service-role key in the Flutter app.

Voice parsing calls the authenticated `parse-expense` Supabase Edge Function.
The Gemini key is read only by that function from Supabase function secrets;
it is never passed to Flutter, a build argument, or a client log.

## Run And Test

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Run the app with `flutter run` after configuring Supabase. Tests use fakes for
external services and do not require production credentials.

## Build

```sh
flutter build apk --debug
flutter build appbundle --release
flutter build ios --simulator
```

The release builds require the corresponding local SDKs and signing/provider
configuration. Do not commit build outputs, Pods, signing files, or local
configuration.

## Database Contract And RLS

The client queries `profiles`, `accounts`, `transactions`, `categories`, and
`bills`, and calls `create_wallet_transactions` and `pay_wallet_bill`. The
actual production schema is not checked into this repository. Verify column
names, foreign keys, RPC authorization, and ownership policies in Supabase.
Every read, insert, update, and delete must be constrained to `auth.uid()`;
RPCs must also enforce ownership server-side.

## Known Limitations

- No migrations or policy files are included, so database security cannot be
	independently verified from this repository.
- The Gemini Edge Function and database migration are prepared locally but are
	not deployed from this repository.
- Google and Apple OAuth require dashboard, redirect URL, and platform setup.
- Bill payment calls a database RPC; it is not an external payment gateway.
- No license has been selected for this repository.

## Future Improvements

- Deploy and use the Gemini Edge Function proxy.
- Add versioned Supabase migrations and automated RLS tests.
- Replace remaining legacy/sample data sources with repositories backed by the
	authenticated Supabase session.
- Add platform integration tests for deep links, OAuth, and speech permissions.
