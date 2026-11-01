# Mono Wallet Guide

This file documents the app structure that exists now, what each page does, and why the current code is shaped the way it is.

## 1. App Start Flow

The app starts in [lib/main.dart](../lib/main.dart). It initializes Flutter bindings, prepares the service locator, and launches `MonoWalletApp`.

The app shell uses `MaterialApp.router`, so navigation is controlled by `go_router` instead of direct `Navigator.push` calls.

The current first-run flow is:

1. Splash screen
2. Onboarding screen
3. Login screen
4. Home shell with bottom navigation

## 2. Main Entry Point

File: [lib/main.dart](../lib/main.dart)

What it does:

- Bootstraps Flutter with `WidgetsFlutterBinding.ensureInitialized()`.
- Calls `setupServiceLocator()` before the UI starts.
- Launches `MonoWalletApp`.
- Uses `MaterialApp.router` so routing comes from a central router object.
- Applies the shared app theme.

Why this is useful:

- Keeps startup logic in one place.
- Makes navigation easier to manage.
- Lets the app scale without hardcoded screen pushes everywhere.

## 3. Router

File: [lib/core/routing/app_router.dart](../lib/core/routing/app_router.dart)

This is the navigation map for the app.

Current routes:

- `/splash` -> splash screen
- `/onboarding` -> onboarding screen
- `/login` -> login screen
- `/home` -> main app shell

The router starts at `/splash`, and `/` redirects to `/splash`.

Why this matters:

- The splash screen appears first automatically.
- The onboarding screen is shown after the splash.
- Login is separated from the main app shell.

## 4. Dependency Injection

File: [lib/service_locator.dart](../lib/service_locator.dart)

This file uses `get_it` as the dependency container.

What is registered now:

- `Dio` as the HTTP client.
- `ApiConsumer` as a wrapper around `Dio`.

Why this matters:

- Shared objects are created once.
- Features can depend on interfaces instead of direct implementations.
- The app is easier to test and extend later.

## 5. Theme and Design Tokens

Files:

- [lib/core/constants/app_colors.dart](../lib/core/constants/app_colors.dart)
- [lib/core/constants/app_styles.dart](../lib/core/constants/app_styles.dart)
- [lib/core/theme/app_theme.dart](../lib/core/theme/app_theme.dart)

### App colors

The current brand colors are:

- Primary: `#3E7C78`
- Secondary: `#69AEA9`

These are used across the onboarding button, gradients, cards, and accent elements.

### App styles

`AppStyles` stores reusable text styles:

- `headingLarge`
- `headingMedium`
- `body`

### App theme

`AppTheme.lightTheme` wires the app-wide Material 3 theme.

It sets:

- shared `ColorScheme`
- background color
- app bar styling
- text theme defaults

Why this matters:

- The app keeps a consistent look.
- Colors and typography are controlled from one place.
- Screens can stay small and focused.

## 6. Splash Screen

File: [lib/features/splash/presentation/views/splash_view.dart](../lib/features/splash/presentation/views/splash_view.dart)

This is the first screen the user sees.

What it does:

- Shows the `mono` wordmark centered.
- Uses a teal gradient background.
- Adds subtle texture dots in the background.
- Animates the logo with fade and scale.
- Shows animated loading dots at the bottom.
- Automatically navigates to `/onboarding` after 2 seconds.

Why it exists:

- It makes the app feel alive immediately.
- It gives a clear brand moment before the onboarding screen.

## 7. Onboarding Screen

File: [lib/features/onboarding/presentation/views/onboarding_view.dart](../lib/features/onboarding/presentation/views/onboarding_view.dart)

This is the marketing/intro screen shown after splash.

What it does:

- Displays the hero illustration from the local SVG asset.
- Uses a soft animated slide/fade/floating effect.
- Shows the message “Spend Smarter / Save More”.
- Includes a large “Get Started” button.
- Includes a “Log In” text link.

Current behavior:

- The button and the login link both navigate to `/login`.

Why it exists:

- It introduces the app value before login.
- It gives a polished first impression.
- It matches the clean wallet-app style.

## 8. Onboarding Illustration Asset

File: [assets/illustrations/onboarding_hero.svg](../assets/illustrations/onboarding_hero.svg)

This is the vector illustration used on the onboarding page.

What it is:

- A local SVG hero image.
- It shows a character with money-related icons.
- It was added as a project asset and registered in `pubspec.yaml`.

Why SVG was used:

- It scales cleanly on different screen sizes.
- It stays sharp on high-resolution devices.
- It is easy to reuse later.

## 9. Login Screen

File: [lib/features/auth/presentation/views/login_view.dart](../lib/features/auth/presentation/views/login_view.dart)

This is the login UI.

What it does:

- Shows a welcome headline.
- Has email and password fields.
- Uses a reusable primary button.

Current behavior:

- The sign-in button currently routes to `/home` as a placeholder flow.

Why it exists:

- It separates auth UI from the home shell.
- It gives a clear place to connect real login logic later.

## 10. Home Shell

File: [lib/features/home/presentation/views/home_view.dart](../lib/features/home/presentation/views/home_view.dart)

This is the main app container after login.

What it does:

- Uses `NavigationBar` for bottom navigation.
- Keeps tab state in an `IndexedStack` so screens stay alive.
- Shows four sections:
  - Home dashboard
  - Statistics
  - Wallet
  - Profile

### Home dashboard

The first tab shows:

- balance summary card
- quick action cards
- recent activity cards

Why it exists:

- It gives the user a quick overview of wallet activity.
- It acts as the landing page of the signed-in app.

## 11. Statistics Page

File: [lib/features/statistics/presentation/views/statistics_view.dart](../lib/features/statistics/presentation/views/statistics_view.dart)

This page shows spending summary information.

Current content:

- title and description
- monthly overview card
- category rows for Food, Transport, Bills, and Others

Why it exists:

- It prepares the app for charts or analytics later.
- It gives a dedicated space for spending insights.

## 12. Wallet Page

File: [lib/features/wallet/presentation/views/wallet_view.dart](../lib/features/wallet/presentation/views/wallet_view.dart)

This page shows wallet accounts.

Current content:

- page title
- short description
- main wallet card
- savings card

Why it exists:

- It creates a dedicated place for balances and payment-related actions.
- It can later grow into bills, cards, and transfers.

## 13. Profile Page

File: [lib/features/profile/presentation/views/profile_view.dart](../lib/features/profile/presentation/views/profile_view.dart)

This page shows account/profile details.

Current content:

- profile title
- short description
- avatar row with name and email

Why it exists:

- It gives a place for settings and account information.
- It can later expand to preferences, security, and support.

## 14. Auth Feature Structure

Files:

- [lib/features/auth/domain/entities/user.dart](../lib/features/auth/domain/entities/user.dart)
- [lib/features/auth/domain/repositories/auth_repository.dart](../lib/features/auth/domain/repositories/auth_repository.dart)
- [lib/features/auth/domain/usecases/sign_in_usecase.dart](../lib/features/auth/domain/usecases/sign_in_usecase.dart)
- [lib/features/auth/data/datasources/auth_local_data_source.dart](../lib/features/auth/data/datasources/auth_local_data_source.dart)
- [lib/features/auth/data/datasources/auth_remote_data_source.dart](../lib/features/auth/data/datasources/auth_remote_data_source.dart)
- [lib/features/auth/data/models/user_model.dart](../lib/features/auth/data/models/user_model.dart)
- [lib/features/auth/data/repositories/auth_repository_impl.dart](../lib/features/auth/data/repositories/auth_repository_impl.dart)
- [lib/features/auth/presentation/cubit/auth_cubit.dart](../lib/features/auth/presentation/cubit/auth_cubit.dart)
- [lib/features/auth/presentation/cubit/auth_state.dart](../lib/features/auth/presentation/cubit/auth_state.dart)
- [lib/features/auth/presentation/widgets/auth_primary_button.dart](../lib/features/auth/presentation/widgets/auth_primary_button.dart)

How it is organized:

- `domain` holds pure business rules.
- `data` holds the implementation details.
- `presentation` holds UI and state management.

Current status:

- The structure is ready.
- The data source methods are still mock/stubbed.
- The UI is connected enough to show the flow.

## 15. Home, Statistics, Wallet, and Profile Feature Structure

Each feature follows the same clean-architecture idea:

- domain entity
- repository interface
- use case
- data source or repository implementation
- presentation screen

Files:

- [lib/features/home](../lib/features/home)
- [lib/features/statistics](../lib/features/statistics)
- [lib/features/wallet](../lib/features/wallet)
- [lib/features/profile](../lib/features/profile)

Why this matters:

- It keeps the app scalable.
- Each feature stays isolated.
- Later API work can be added without changing the whole app.

## 16. Network Layer

File: [lib/core/network/api_consumer.dart](../lib/core/network/api_consumer.dart)

This file wraps `Dio` behind a simple interface.

What it provides:

- `get`
- `post`

Why it exists:

- Features can use a shared API interface.
- It reduces direct dependency on `Dio` everywhere.

## 17. Helpers

File: [lib/core/utils/helpers.dart](../lib/core/utils/helpers.dart)

This file contains small extension helpers:

- `ContextHelpers`
- `StringHelpers`

Why it exists:

- It keeps repeated small logic out of screens.
- It makes UI code a little cleaner.

## 18. Dependencies Added

File: [pubspec.yaml](../pubspec.yaml)

Added packages:

- `dio` for networking
- `equatable` for value equality in states or entities
- `flutter_bloc` for state management
- `get_it` for dependency injection
- `go_router` for routing
- `flutter_svg` for the onboarding SVG image

## 19. Asset Registration

File: [pubspec.yaml](../pubspec.yaml)

The onboarding SVG is registered here:

- `assets/illustrations/onboarding_hero.svg`

This is required so Flutter can bundle and load the image.

## 20. Validation

The app has already been checked with:

- `flutter analyze`
- `flutter test test/widget_test.dart`

Both pass at the current state.

## 21. Current User Flow Summary

1. App starts in splash.
2. Splash animates and routes to onboarding.
3. Onboarding shows the hero image and CTA.
4. “Get Started” or “Log In” goes to login.
5. Login can go to home.
6. Home contains the bottom navigation sections.

## 22. Notes

- Some data sources and repository implementations are still placeholder/mock logic.
- The visual structure is in place, but the app is not yet wired to a real backend.
- The architecture is ready for that next step.