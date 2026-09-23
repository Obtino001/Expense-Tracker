# Firebase Backend — Schema & Setup

This document describes the Firebase backend for the Budget app: collections,
documents, fields, and how to wire it all up.

## 1. Provisioning

```bash
# 1. Install the Firebase + FlutterFire CLIs
npm i -g firebase-tools
dart pub global activate flutterfire_cli

# 2. Log in, create a project, configure platforms
firebase login
firebase projects:create budget-app
flutterfire configure --project=budget-app
#   -> overwrites lib/firebase_options.dart with real values

# 3. Enable the services in the console:
#    - Authentication → Email/Password
#    - Firestore (start in production mode)
#    - Cloud Messaging
#    - Crashlytics
#    - Analytics

# 4. Deploy rules + indexes
firebase deploy --only firestore:rules,firestore:indexes
```

## 2. Firestore Schema

```
users/{uid}                                  ← profile
  ├── id              string  (== uid)
  ├── name            string
  ├── email           string
  ├── avatarUrl       string?
  ├── currency        string  ("USD")
  ├── fcmTokens       string[]   (multi-device push)
  └── createdAt       timestamp  (server)

users/{uid}/transactions/{txId}
  ├── id              string
  ├── userId          string  (== uid, enforced by rules)
  ├── title           string  (≤120 chars)
  ├── amount          number  (>0)
  ├── date            timestamp
  ├── yearMonth       string  ("2026-05")    ← for monthly queries
  ├── type            string  ("income"|"expense")
  ├── note            string
  └── category        map { id, name, iconCode, iconFontFamily,
                            iconFontPackage, color, isIncome }

users/{uid}/budgets/{budgetId}
  ├── id              string
  ├── userId          string
  ├── category        map
  ├── limit           number  (>0)
  ├── spent           number  (Cloud Function or write-through)
  └── period          string  ("April")

users/{uid}/categories/{categoryId}          ← per-user category list
  └── (same shape as the embedded `category` map above)

users/{uid}/notifications/{notifId}          ← in-app feed
  ├── id              string
  ├── title           string
  ├── message         string
  ├── time            timestamp
  ├── type            string  (info|success|warning|alert)
  └── isRead          bool

users/{uid}/analytics_monthly/{yyyy-MM}       ← monthly rollup
  ├── yearMonth         string ("2026-05")
  ├── income            number
  ├── expense           number
  ├── byCategory        map<string, number>
  ├── dailyExpense      number[31]
  ├── transactionCount  int
  └── updatedAt         timestamp  (server)

categories/{categoryId}                       ← global defaults (read-only)
```

## 3. Security Rules — TL;DR

See [firestore.rules](firestore.rules). Highlights:
- A user can only read/write their own `users/{uid}/...` subtree.
- Profile create/update is validated (email must match `auth.token.email`,
  immutable `id`).
- Transactions must include `userId == auth.uid`, `amount > 0`, valid `type`.
- Notifications are server-created; the client can only flip `isRead`.
- Global `categories/*` is readable by signed-in users, writable by no one.
- Default-deny on everything else.

## 4. Cloud Functions (recommended)

The app works without Functions — it computes monthly analytics client-side
and trusts the client to keep `budgets.spent` in sync. For production, add:

```js
// onWrite on users/{uid}/transactions/{txId}:
//   1. Recompute users/{uid}/analytics_monthly/{yearMonth}
//   2. Recompute users/{uid}/budgets/* spent totals for that category
//   3. Push a budget-alert notification when spent crosses 90%
```

Sample skeleton (deploy via `firebase deploy --only functions`):

```js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onTransactionWrite = functions.firestore
  .document("users/{uid}/transactions/{txId}")
  .onWrite(async (change, ctx) => {
    const { uid } = ctx.params;
    const after = change.after.data();
    const before = change.before.data();
    const yearMonth = (after || before).yearMonth;
    // ...aggregate + push FCM if needed
  });
```

## 5. Push Notifications

- Permission is requested at sign-in via `NotificationService.requestPermission()`.
- The device's FCM token is appended to `users/{uid}.fcmTokens` (array union, multi-device).
- Send a push by looking up the user's tokens and calling
  `admin.messaging().sendEachForMulticast({ tokens, notification, data })`.
- Foreground messages are turned into local heads-up notifications via
  `flutter_local_notifications` (channel `budget_default`).

### iOS extra setup
- Enable **Push Notifications** and **Background Modes → Remote notifications**
  in Xcode.
- Upload your APNs auth key to Firebase → Project settings → Cloud Messaging.

## 6. Analytics

`AnalyticsService` ([lib/core/services/analytics_service.dart](lib/core/services/analytics_service.dart)) wraps
`firebase_analytics`. The router uses `FirebaseAnalyticsObserver` to log
every screen view automatically. Domain events:

| Event              | Params                                |
| ------------------ | ------------------------------------- |
| `sign_up`          | `signUpMethod`                        |
| `login`            | `loginMethod`                         |
| `transaction_added`| `amount`, `type`, `category`          |
| `budget_created`   | `category`, `limit`                   |

## 7. Crashlytics

`main.dart` wires three error channels:
- `FlutterError.onError` → `recordFlutterFatalError`
- `PlatformDispatcher.instance.onError` → `recordError(..., fatal: true)`
- Whole-app `runZonedGuarded` catch-all
- Auto-disabled in debug mode (`!kDebugMode`).

Tag the current user via `CrashlyticsService.setUser(uid)` (already done in
`postSignInBootstrapProvider`).

## 8. Real-time Sync

Every list screen subscribes to a Firestore stream via Riverpod's
`StreamProvider`. Writes from any device propagate instantly:

- `transactionsProvider`  → `users/{uid}/transactions`, ordered by `date desc`
- `categoriesProvider`    → `users/{uid}/categories`
- `budgetsProvider`       → `users/{uid}/budgets`
- `notificationsProvider` → `users/{uid}/notifications`, latest 50
- `userProvider`          → `users/{uid}`

## 9. Local Emulators (dev)

```bash
firebase emulators:start
# Auth: http://localhost:9099
# Firestore: http://localhost:8080
# UI: http://localhost:4000
```

Point the app at them in `main.dart` (after `Firebase.initializeApp`):

```dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```
