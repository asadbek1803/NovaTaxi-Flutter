# Nova Taxi Driver App

A modern Flutter driver application for Nova Taxi ride-hailing service, specifically designed for the Uzbekistan market.

## Features

### Authentication & Onboarding
- **Phone Number Login**: Modern login screen with +998 Uzbekistan phone format
- **OTP Verification**: Secure SMS-based verification with countdown timer
- **Driver Onboarding**: Multi-step registration process
  - Vehicle Information (car model, color, license plate)
  - Personal Information (full name, driver's license)
  - Passport Scanner with overlay mask
  - Auto-Capture Selfie using ML Kit Face Detection
  - Car Photo upload
- **Moderator Approval**: Pending status screen with real-time notifications
- **Rejection Handling**: Rejection screen with reason display and re-upload option

### Driver Features
- **Order Management**: Real-time order acceptance with countdown timer
- **Navigation**: Pickup navigation with animated route display
- **Earnings Tracking**: Daily earnings overview with detailed records
- **Rating System**: Driver rating and feedback display
- **Online/Offline Toggle**: Easy status switching with background service
- **Push Notifications**: Firebase Cloud Messaging for real-time updates

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # API endpoints, storage keys, constants
│   └── theme/
│       └── app_theme.dart              # App theming (light/dark mode)
├── features/
│   ├── auth/                           # Authentication module
│   │   ├── models/
│   │   │   └── driver_model.dart       # Driver data model
│   │   ├── providers/
│   │   │   └── auth_provider.dart      # Authentication state management
│   │   ├── screens/
│   │   │   ├── phone_number_screen.dart
│   │   │   └── otp_screen.dart
│   │   ├── services/
│   │   └── widgets/
│   ├── onboarding/                     # Driver onboarding module
│   │   ├── models/
│   │   │   └── onboarding_data.dart    # Onboarding data models
│   │   ├── providers/
│   │   │   └── onboarding_provider.dart # Onboarding state management
│   │   ├── screens/
│   │   │   ├── vehicle_info_screen.dart
│   │   │   ├── personal_info_screen.dart
│   │   │   ├── passport_scanner_screen.dart
│   │   │   ├── selfie_capture_screen.dart
│   │   │   ├── car_photo_screen.dart
│   │   │   ├── onboarding_wrapper.dart
│   │   │   └── pending_status_screen.dart
│   │   ├── services/
│   │   └── widgets/
│   └── home/                           # Main driver dashboard
│       ├── models/
│       │   └── order_model.dart        # Order data model
│       ├── providers/
│       ├── screens/
│       │   ├── driver_home_screen.dart
│       │   ├── earnings_screen.dart
│       │   ├── ratings_screen.dart
│       │   ├── profile_screen.dart
│       │   ├── order_details_screen.dart
│       │   ├── pickup_navigation_screen.dart
│       │   └── home_wrapper.dart
│       ├── services/
│       └── widgets/
│           ├── map_placeholder.dart
│           ├── online_toggle.dart
│           ├── order_accept_button.dart
│           └── route_map_painter.dart
├── shared/                             # Shared utilities
│   ├── models/
│   ├── services/
│   │   ├── api_service.dart            # HTTP API client
│   │   ├── fcm_service.dart            # Firebase Cloud Messaging
│   │   ├── driver_background_service.dart
│   │   └── notification_service.dart
│   └── widgets/
└── main.dart                           # App entry point
```

## Technology Stack

### Core Framework
- **Flutter**: ^3.12.2
- **Dart**: SDK ^3.12.2

### State Management
- **Provider**: ^6.1.2

### Camera & Image Processing
- **Camera**: ^0.10.5+9
- **Google ML Kit Face Detection**: ^0.11.0
- **Image Picker**: ^1.0.7

### Authentication & Storage
- **Firebase Core**: ^3.3.0
- **Firebase Messaging**: ^15.1.0
- **Shared Preferences**: ^2.2.2

### Networking
- **HTTP**: ^1.2.0

### UI Components
- **Pinput**: ^4.0.1 (OTP input)

### Background Services
- **Flutter Local Notifications**: ^19.4.0
- **Flutter Background Service**: ^5.1.0
- **Permission Handler**: ^12.0.1
- **Audio Players**: ^6.5.0

## Getting Started

### Prerequisites
- Flutter SDK (3.12.2 or higher)
- Dart SDK (3.12.2 or higher)
- Android Studio / Xcode
- Firebase project with FCM enabled

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd nova_driver
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Add `google-services.json` for Android
- Add `GoogleService-Info.plist` for iOS
- Enable Firebase Cloud Messaging in Firebase Console

4. Run the app:
```bash
flutter run
```

## Configuration

### API Configuration
Update `lib/core/constants/app_constants.dart` with your backend API:
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

### Firebase Configuration
Follow the [Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup) to configure Firebase for your project.

## Key Features Implementation

### Authentication Flow
1. User enters phone number with +998 format
2. OTP is sent via SMS
3. User verifies OTP
4. Based on driver status, navigates to:
   - Onboarding (new driver)
   - Pending status (awaiting approval)
   - Home screen (approved driver)

### Onboarding Stepper
5-step process:
1. Vehicle Information
2. Personal Information
3. Passport Photo (with overlay mask)
4. Selfie (auto-capture with face detection)
5. Car Photo

### Face Detection
- Uses Google ML Kit for real-time face detection
- Automatically captures photo when face is centered and stable
- Visual feedback with progress indicator

### Push Notifications
- Firebase Cloud Messaging for moderator decisions
- Background message handling
- In-app notification display

## Development Guidelines

### Code Style
- Follow Flutter/Dart official style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

### State Management
- Use Provider for state management
- Separate business logic from UI
- Use ChangeNotifier for state classes

### File Organization
- Feature-based folder structure
- Separate models, providers, screens, services
- Shared utilities in `shared/` folder
- Core constants and theme in `core/` folder

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## License

Proprietary - Nova Taxi

## Support

For support, contact the development team at support@novataxi.uz
