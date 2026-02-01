# iOS Build Instructions

## Prerequisites

To build this app for iOS, you need:

1. **macOS** (Big Sur 11.0 or later recommended)
2. **Xcode** (14.0 or later)
3. **CocoaPods** - Install with: `sudo gem install cocoapods`
4. **Flutter SDK** - Properly configured on macOS

## Build Steps

### 1. Install Dependencies

```bash
# Navigate to project root
cd budget_manage

# Get Flutter packages
flutter pub get

# Navigate to iOS folder
cd ios

# Install CocoaPods dependencies
pod install
```

### 2. Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode (NOT Runner.xcodeproj)
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Select your Team
5. Change the Bundle Identifier if needed (currently: `com.darahat.budgetmanage`)

### 3. Build for iOS

#### Option A: Using Flutter CLI

```bash
# Build for iOS simulator
flutter build ios --simulator

# Build for physical device
flutter build ios --release
```

#### Option B: Using Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your target device/simulator
3. Click the Run button (▶️) or press Cmd+R

## App Configuration

- **Bundle Identifier**: `com.darahat.budgetmanage`
- **Display Name**: Budget Manager
- **Minimum iOS Version**: 12.0
- **Supported Orientations**:
  - iPhone: Portrait, Landscape Left, Landscape Right
  - iPad: All orientations

## Deployment

### TestFlight Distribution

```bash
# Build and archive
flutter build ipa

# Upload to App Store Connect via Xcode or Transporter app
```

### App Store Submission

1. Ensure all required app icons are in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Update version in `pubspec.yaml`
3. Build IPA: `flutter build ipa --release`
4. Upload via Transporter or Xcode
5. Submit through App Store Connect

## Troubleshooting

### CocoaPods Issues

```bash
cd ios
pod repo update
pod install --repo-update
```

### Clean Build

```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

### Common Errors

- **"DT_TOOLCHAIN_DIR cannot be used"**: Update Xcode to latest version
- **Signing errors**: Configure signing in Xcode project settings
- **Pod install fails**: Try `pod repo update` first

## Notes

- The iOS configuration is ready but requires macOS with Xcode to build
- All dependencies are configured in `ios/Podfile`
- App uses SharedPreferences (via UserDefaults on iOS)
- No special permissions required (no camera, location, etc.)
