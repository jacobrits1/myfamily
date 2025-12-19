# App Logo Setup Instructions

## Adding Logo as Launcher Icon

To set the app logo as the launcher icon, you need to replace the existing launcher icons with your logo image.

### Step 1: Prepare Logo Image
- Your logo should be a square image (recommended: 1024x1024 pixels)
- Save it as PNG format with transparent background (if needed)

### Step 2: Generate App Icons
You can use Flutter's `flutter_launcher_icons` package or manually replace the icons.

#### Option A: Using flutter_launcher_icons (Recommended)

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo.png"  # Path to your logo
```

2. Run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

#### Option B: Manual Replacement

Replace the following files with your logo in appropriate sizes:

**Android:**
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

**iOS:**
- Replace files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Step 3: Create Assets Directory
1. Create `assets/` folder in project root
2. Place your logo file there (e.g., `assets/logo.png`)

### Step 4: Update pubspec.yaml
Add assets section:
```yaml
flutter:
  assets:
    - assets/logo.png
```

## Current Status
- Logo integration guide created
- Ready to add logo file and generate icons

