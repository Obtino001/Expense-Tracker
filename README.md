# Budget — Premium Flutter Budget Tracker

A production-level Flutter budget tracking app with extremely modern UI, smooth premium
animations, and a Revolut/Stripe-level finish. Built with Flutter, Material 3, Riverpod,
and GoRouter.

## Features
- Beautiful animated onboarding (3 pages, gradient illustrations)
- Home dashboard with hero balance card, quick actions, recent transactions
- Add transaction screen (income/expense, category chips, date picker)
- Analytics with weekly bar chart and category donut breakdown
- Budget goals with animated progress
- Category management (grid view)
- Profile, notifications, and settings screens
- Dark + light Material 3 themes
- Glassmorphism, gradients, micro-interactions, haptic feedback
- Skeleton loaders (shimmer)
- Smooth page transitions (fadeThrough + slideUp)
- Responsive layout helpers
- Mock data ready to plug a real backend

## Tech Stack
- Flutter (latest stable)
- Riverpod (`flutter_riverpod`) — state management
- GoRouter — declarative routing
- Material 3 + Google Fonts (Plus Jakarta Sans)
- flutter_animate, flutter_staggered_animations — animations
- fl_chart — charts
- shimmer — skeleton loaders
- smooth_page_indicator — onboarding dots

## Folder Structure
```
lib/
├── main.dart                      Entry point
├── app.dart                       Root MaterialApp.router
│
├── core/                          Cross-cutting concerns
│   ├── animations/                Page transitions, durations, curves
│   ├── constants/                 Colors, sizes, strings
│   ├── router/                    GoRouter setup, route names
│   ├── theme/                     Light + dark Material 3 themes
│   └── utils/                     Formatters, extensions, responsive
│
├── data/                          Data layer
│   ├── mock/                      Hard-coded sample data
│   ├── models/                    Plain Dart models
│   └── repositories/              Repos with simulated network delay
│
├── features/                      Feature-first vertical slices
│   ├── analytics/presentation/
│   ├── budget/presentation/
│   ├── categories/presentation/
│   ├── home/presentation/
│   ├── notifications/presentation/
│   ├── onboarding/presentation/
│   ├── profile/presentation/
│   ├── settings/presentation/
│   └── transactions/presentation/
│
└── shared/                        App-wide reusable widgets + providers
    ├── providers/                 Riverpod providers (theme, txs, user)
    └── widgets/                   GlassCard, GradientButton, BottomNav, etc.
```

## Getting Started

```bash
flutter pub get
flutter run
```

Tested with Flutter 3.24+. On first run you'll see the onboarding flow,
then the main shell with bottom navigation.

## Architecture Notes

- **Feature-first layout** — each feature has its own `presentation/screens` and
  `presentation/widgets` folders. This scales much better than grouping by type.
- **Riverpod** — repositories live in `Provider`s, async data uses `FutureProvider`,
  UI state uses `StateProvider`. Easy to override in tests.
- **GoRouter** — `ShellRoute` wraps the four tabs so the bottom nav persists.
  Modal-style screens (Add transaction, Settings, etc.) push on top.
- **Animations** — single source of truth for durations/curves in
  `core/animations/animation_constants.dart`. Page transitions in
  `page_transitions.dart` keep go_router pages consistent.
- **Theme** — fully Material 3, both light and dark. Plus Jakarta Sans via
  `google_fonts`. Brand color is electric violet `#6C5CE7`.

## Best Packages Used

| Concern        | Package                                       |
| -------------- | --------------------------------------------- |
| State          | `flutter_riverpod`, `riverpod_annotation`     |
| Routing        | `go_router`                                   |
| Animation      | `flutter_animate`, `flutter_staggered_animations` |
| Charts         | `fl_chart`                                    |
| Fonts          | `google_fonts`                                |
| Icons / SVG    | `flutter_svg`                                 |
| Skeletons      | `shimmer`                                     |
| Indicators     | `smooth_page_indicator`                       |
| Date / number  | `intl`                                        |
| IDs            | `uuid`                                        |
| Persistence    | `shared_preferences`                          |
| Lottie         | `lottie`                                      |

## Firebase Backend

This project ships with a full Firebase backend (Auth, Firestore, Messaging,
Analytics, Crashlytics). See **[FIREBASE.md](FIREBASE.md)** for:

- Provisioning steps (`firebase init`, `flutterfire configure`)
- Full collection/document schema
- Security rules walkthrough
- Cloud Function recipes for monthly analytics + budget alerts
- Push-notification setup (incl. iOS APNs)
- Local emulator config

## Next Steps
- Run `flutterfire configure` to replace the placeholder `firebase_options.dart`.
- Deploy rules: `firebase deploy --only firestore:rules,firestore:indexes`.
- Add Cloud Functions to aggregate `analytics_monthly` server-side.
- Add `freezed` if you want code-generated unions/equals.
- Add localization with `flutter_intl`.
- Write widget tests for each screen.
