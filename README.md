# Creatoo

Creatoo is a Flutter-based mobile application built for a reward-based discovery platform. Users can explore local businesses, earn rewards via Creatoo Points, and enjoy personalized experiences. The app supports **Business** and **Creator** roles with distinct onboarding, dashboard, and wallet flows.

---

## 🚀 Features

- **Onboarding flow** for new users
- **Business & Creator user roles** with separate registration flows
- **Dynamic discount logic** with loyalty points (Creatoo Points)
- **Wallet & Rewards system** with transfer, withdrawal, and transaction history
- **Payment Gateway Integration** — Razorpay (primary) + PhonePe (secondary)
- **Admin-controlled notifications** — dynamic & custom via Firebase Cloud Messaging
- **QR Code Scanner & Generator** for visit/payment flows
- **Advanced Search** — businesses, creators, turf options, exclusive offers
- **Booking System** — create, manage, cancel, and advance bookings
- **Post & Opportunity Management** — creators can post, businesses can apply/release payments
- **Settlement & Report System** — wallet settlement, advance payments, transaction reports
- **Bill Payment & Checkout** — apply offers, process payments, calculate discounts
- **Deep Linking** — Android App Links & iOS Universal Links for scan & payment flows
- **Force Update** — via Upgrader package with admin-controlled versioning
- **OTP Autofill** — SMS retriever + smart auth for seamless login
- **Exclusive Offers** — explore and apply business-specific exclusive deals

---

## 📱 Tech Stack & Versions

| Technology | Version |
|---|---|
| **Flutter** | 3.38.6 (stable channel via FVM) |
| **Dart** | 3.10.7 |
| **SDK Constraint** | `>=3.3.0 <4.0.0` |
| **App Version** | `1.2.2+61` |

### Android

| Property | Value |
|---|---|
| **Namespace** | `com.creatoo.app` |
| **Compile SDK** | 36 |
| **Min SDK** | Flutter default (~21) |
| **Target SDK** | 36 |
| **Java Version** | 11 |
| **Kotlin** | 2.1.0 |
| **AGP** | 8.7.3 |
| **Gradle** | 8.10-all |
| **Firebase Google Services** | 4.4.0 |
| **MultiDex** | Enabled |
| **R8 Minify** | Enabled (shrinkResources: false) |
| **Desugar** | 2.0.3 |

### iOS

| Property | Value |
|---|---|
| **Bundle ID** | `com.creatoo.creatooapp` |
| **Deployment Target** | iOS 15.5 |
| **Swift** | Default (Swift 5) |
| **Deep Linking** | Associated Domain: `applinks:api.creatoo.co.in` |
| **Custom URL Scheme** | `creatoo://` |
| **Background Modes** | Fetch, Processing, Remote Notification |

### Supported Platforms

Android, iOS, Linux, macOS, Web, Windows (all configured via `.metadata`)

---

## 📦 Dependencies

### Production (63 packages)

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core Flutter framework |
| `cached_network_image` | ^3.4.1 | Network image caching |
| `carousel_slider` | ^5.0.0 | Banner/carousel widget |
| `cupertino_icons` | ^1.0.6 | iOS-style icons |
| `fluttertoast` | ^8.2.12 | Toast notifications |
| `http` | ^1.3.0 | HTTP client |
| `another_flushbar` | ^1.12.30 | Custom snackbar/toast |
| `provider` | ^6.0.5 | State management (MVVM) |
| `shared_preferences` | ^2.5.2 | Local key-value persistence |
| `dartz` | ^0.10.1 | Functional error handling (Either) |
| `pinput` | ^5.0.0 | OTP input field |
| `smart_auth` | ^2.0.0 | SMS autofill |
| `otp_autofill` | ^4.1.0 | OTP auto-fill via SMS |
| `dropdown_search` | ^5.0.6 | Searchable dropdown |
| `image_picker` | ^1.1.2 | Camera/gallery image picker |
| `flutter_image_compress` | ^2.3.0 | Image compression |
| `firebase_core` | ^3.1.0 | Firebase core |
| `firebase_messaging` | ^15.0.1 | Firebase Cloud Messaging |
| `flutter_local_notifications` | ^18.0.1 | Local push notifications |
| `flutter_html` | ^3.0.0-beta.2 | HTML rendering |
| `webview_flutter` | ^4.8.0 | WebView support |
| `razorpay_flutter` | ^1.4.0 | Razorpay payment gateway |
| `intl` | ^0.20.2 | Internationalization / formatting |
| `get` | ^4.6.6 | DI / navigation (limited use) |
| `mobile_scanner` | ^6.0.2 | QR/barcode scanning |
| `dio` | ^5.0.0 | Alternative HTTP client |
| `flutter_svg` | — | SVG rendering |
| `google_fonts` | — | Google Fonts (Montserrat) |
| `flutter_native_splash` | — | Native splash screen |
| `lottie` | — | Lottie animations |
| `url_launcher` | ^6.3.0 | Open external URLs |
| `jwt_decoder` | ^2.0.1 | JWT token decoding |
| `device_preview` | ^1.2.0 | Device preview/testing |
| `permission_handler` | — | Runtime permissions |
| `device_info_plus` | ^11.5.0 | Device information |
| `path_provider` | ^2.1.5 | File system paths |
| `image_gallery_saver_plus` | ^4.0.1 | Save images to gallery |
| `dotted_border` | ^2.1.0 | Dotted border container |
| `video_player` | ^2.8.1 | Video playback |
| `shimmer` | ^2.0.0 | Shimmer loading effect |
| `photo_view` | ^0.15.0 | Pinch-to-zoom images |
| `crypto` | ^3.0.6 | Cryptographic hashing |
| `confetti` | ^0.7.0 | Confetti animation |
| `upgrader` | ^11.4.0 | Force update prompts |
| `animated_button` | ^0.2.0 | Animated buttons |
| `app_links` | ^6.3.2 | Deep linking |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `table_calendar` | ^3.1.2 | Calendar widget |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Flutter testing framework |
| `flutter_lints` | ^3.0.0 | Lint rules |

---

## 🏗 Architecture

| Aspect | Detail |
|---|---|
| **Pattern** | MVVM (Model-View-ViewModel) |
| **State Management** | Provider (ChangeNotifier) |
| **Navigation** | Named routes with `onGenerateRoute` |
| **Networking** | `http` package via custom `NetworkApiService` |
| **Error Handling** | `Either<AppException, T>` via `dartz` |
| **Theme** | Light theme, primary: `#9759C4` (purple) |
| **Fonts** | Montserrat (Google Fonts) + SFUIText (custom, 22 variants) |

### Folder Structure

```
lib/
├── main.dart
├── core.dart                      # Barrel export
├── firebase_options.dart          # Firebase config (auto-generated)
├── data/
│   ├── network/                   # API layer (BaseApiServices, NetworkApiService)
│   ├── response/                  # Response models & parser
│   └── services/                  # Firebase, Razorpay, PhonePe, SharedPrefs, etc.
├── resources/                     # Colors, constants, URLs, icons, images
├── utils/                         # Helpers, enums, extensions, theme, routes, providers
├── widgets/                       # 41 reusable UI components
└── features/                      # 42 feature modules (each with model/view/view_model)
```

### Features (42 modules)

`add_post`, `add_post_payment_summary`, `auth`, `bill_payment`, `booking`, `business`, `business_category_setup`, `business_payments`, `business_profile`, `business_visits`, `card`, `category`, `coming_soon`, `creator_contact`, `creator_home`, `creator_profile`, `creator_wallet`, `earn_creatoo_points`, `feedback`, `force_update`, `home`, `notification`, `onboarding`, `opportunity`, `payment_details`, `post`, `post_detail`, `qr_pay`, `register_business`, `register_creator`, `review`, `scanner`, `search`, `settings`, `shortlist`, `splash`, `startup`, `user_payments`, `user_points`, `verify_otp`, `visits`, `wallet`

---

## 🌐 Backend

| Property | Detail |
|---|---|
| **API Base URL** | `https://api.creatoo.co.in/api` |
| **Environment** | Production |
| **API Style** | RESTful JSON API |
| **Auth** | JWT-based token authentication |
| **Firebase Project** | `creatoo-2b4b1` |
| **Storage Bucket** | `creatoo-2b4b1.appspot.com` |

### API Endpoints (60+)

- **Auth** — login, register (business/creator), OTP send/verify, logout
- **User Profile** — view/edit business & creator profiles, Instagram verification
- **Home & Search** — home feed, creator home, search, turf options, exclusive offers
- **Cards** — check, verify, auto-assign
- **Visits** — today's visits, user history, add visit
- **Posts & Opportunities** — create, list, interest, applications, release payments
- **Payments & Wallet** — transactions, withdraw, payment details, release
- **Manual Payments** — calculate, submit, confirm, cancel, stats
- **Creatoo Points** — transactions, validate, transfer
- **Business Settings** — discount, description, subscription
- **Cart & Shortlist**
- **Orders & Checkout** — create order, apply offers, process payment
- **Reviews & Feedback**
- **Notifications** — push notifications via FCM
- **Version Verification** — force update control
- **Settlement** — summary, transactions, history, advance payments
- **Bookings** — create, list, update status, cancel, advance
- **Exclusive Offers** — CRUD & apply

---

## 🧮 Reward & Discount Logic

### Earning Creatoo Points

- Users earn loyalty points (Creatoo Points) based on the **discount applied on their bill**.
- **Formula:**  
  **Points Earned = Discount Applied (%) × 2 × Final Bill Amount (after discount, before charges)**
- Points are **business-specific**: earned at Business A can only be redeemed at Business A.

### Discount Application Rules

Each business defines:
- **First-time discount** — applied only on the first visit
- **Regular discount** — applied from second visit onward
- **Minimum discount threshold** — enforced during redemption (admin-only visible)
- **Platform fee (PF)** and **Gateway charges** (admin-configurable)

### First Visit Flow

- User has 0 points → full first-time discount is applied
- Points are earned per the discount used
- Final payable = Discounted Amount + Gateway Charges (%) + Platform Fee

### Return Visit Scenarios

1. **Points exactly match discount requirement** → full regular discount applied, all eligible points used, new points earned
2. **Insufficient points for full discount** → discount calculated from available points via reverse calculation; if ≥ minimum threshold, apply it; if < minimum threshold, apply minimum discount instead (platform silently covers the buffer)
3. **Excess points available** → only required points for max regular discount deducted, remaining points stay in wallet

### Wallet Logic

- While displaying available points, a **reverse calculation** is performed using reverse gateway charge (e.g., 2.30%) to estimate discount power
- Reverse gateway & PF configured via admin panel

---

## 🧪 Lint Rules

Uses `flutter_lints` recommended rules with the following disabled:

```yaml
linter:
  rules:
    prefer_const_constructors: false
    prefer_const_declarations: false
    prefer_const_constructors_in_immutables: false
    prefer_const_literals_to_create_immutables: false
    prefer_constructors_over_static_methods: false
```

---

## ⚙️ Configuration

| File | Purpose |
|---|---|
| `pubspec.yaml` | Project dependencies & config |
| `analysis_options.yaml` | Lint rules |
| `firebase.json` | Firebase project config |
| `env/.env` | Razorpay test keys (gitignored) |
| `.fvmrc` | Flutter version management (stable channel) |
| `android/key.properties` | Keystore credentials for release builds |
| `android/app/creatoo-keystore.jks` | Release signing keystore |

---

## 🛠 Development Setup

```bash
# 1. Ensure FVM is installed and use the correct Flutter version
fvm use

# 2. Install dependencies
fvm flutter pub get

# 3. Generate Firebase options (if reconfiguring)
fvm flutterfire configure

# 4. Run the app
fvm flutter run
```

### iOS Build

```bash
fvm flutter build ios --no-codesign
```

### Android Build

```bash
fvm flutter build appbundle
```

---

## 🔗 Deep Linking

- **Android App Links**: `https://api.creatoo.co.in/api/scan?businessId=XYZ`
- **iOS Universal Links**: Same URL pattern with associated domain
- **Custom Scheme**: `creatoo://`
- Handles cold start / warm start navigation with retry logic

---

## 💳 Payment Integration

| Gateway | Integration |
|---|---|
| **Razorpay** | Primary — `razorpay_flutter` package |
| **PhonePe** | Secondary — custom SDK integration |
| **UPI Apps** | tez://, phonepe://, paytmmp://, credpay://, bhim://, amazonpay://, whatsapp:// |

---

## 🔔 Notifications

- **Firebase Cloud Messaging** — remote push notifications
- **Flutter Local Notifications** — local notification display
- **Admin-controlled** — dynamic and custom notification support

---

## 📄 License

Private project — all rights reserved.
