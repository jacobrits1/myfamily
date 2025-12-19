# Logo Setup Instructions

## Your Logo Description
- **Type:** Circular icon
- **Background:** Teal/blue-green (#0891B2)
- **Content:** Three white family silhouettes
  - Left: Male figure (tallest)
  - Middle: Child figure (shortest)  
  - Right: Female figure (tall, dress shape)

## Setup Steps

### Step 1: Add Logo File
1. Save your logo as `logo.png`
2. Place it in the `assets/` folder
3. File path should be: `assets/logo.png`

### Step 2: Generate Launcher Icons
Once the logo file is in place, run:

```bash
flutter pub run flutter_launcher_icons
```

This command will:
- Generate all required icon sizes for Android
- Generate all required icon sizes for iOS
- Update the app launcher icons automatically

### Step 3: Rebuild App
After generating icons, rebuild the app:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Current Configuration

The `pubspec.yaml` is already configured with:
- ✅ `flutter_launcher_icons` package added
- ✅ Image path: `assets/logo.png`
- ✅ Adaptive icon background: Teal (#0891B2)
- ✅ Android and iOS enabled

## Icon Sizes Generated

The tool will automatically create:
- **Android:** mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
- **iOS:** All required sizes for AppIcon

## Next Steps

1. **Place logo file:** Save your logo as `assets/logo.png`
2. **Generate icons:** Run `flutter pub run flutter_launcher_icons`
3. **Rebuild app:** Clean and rebuild to see new icons
4. **Test:** Launch app and verify icon appears on device

## Note

The logo should be:
- Square format (1024x1024 recommended)
- PNG format
- High quality
- Matches your teal background with white family silhouettes

Once you add the logo file, I can help generate the icons!

