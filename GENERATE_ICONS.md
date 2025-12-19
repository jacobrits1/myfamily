# Generate Launcher Icons - Quick Guide

## Your Logo
- **File needed:** `assets/logo.png`
- **Description:** Circular teal background with three white family silhouettes
- **Recommended size:** 1024x1024 pixels

## Steps to Generate Icons

### 1. Add Logo File
Place your logo file at: `assets/logo.png`

### 2. Generate Icons
Run this command:
```bash
flutter pub run flutter_launcher_icons
```

### 3. Rebuild App
After generating icons:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 4. Test
Launch the app and verify the new icon appears on the emulator home screen.

## What Gets Generated

The tool automatically creates:
- **Android icons:** All required sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- **iOS icons:** All AppIcon sizes
- **Adaptive icons:** For modern Android devices

## Current Configuration

✅ `pubspec.yaml` is configured
✅ Assets directory created
✅ Icon generation ready

**Just add the logo file and run the generation command!**

