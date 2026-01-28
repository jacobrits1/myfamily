# Fixing Emulator Storage Issue

## Problem
```
INSTALL_FAILED_INSUFFICIENT_STORAGE: Failed to override installation location
```

## Solutions

### Solution 1: Clear Emulator Data (Recommended)
1. Close the emulator
2. Open Android Studio
3. Go to **Tools → Device Manager**
4. Find your emulator (Medium Phone API 35)
5. Click the **▼** dropdown → **Wipe Data**
6. Restart emulator
7. Try installing again

### Solution 2: Increase Emulator Storage
1. Open Android Studio
2. Go to **Tools → Device Manager**
3. Click **Edit** (pencil icon) on your emulator
4. Click **Show Advanced Settings**
5. Increase **Internal Storage** (e.g., from 2GB to 4GB)
6. Click **Finish**
7. Wipe data and restart emulator

### Solution 3: Use Cold Boot
1. Close emulator completely
2. In Android Studio Device Manager:
   - Click **▼** dropdown → **Cold Boot Now**
3. This clears cache and may free space

### Solution 4: Manual ADB Uninstall (If ADB is in PATH)
```bash
adb -s emulator-5554 uninstall com.example.myfamily
adb -s emulator-5554 shell pm clear com.example.myfamily
```

### Solution 5: Create New Emulator with More Storage
1. Android Studio → Device Manager
2. **Create Device**
3. Choose device → **Next**
4. Download/Select system image → **Next**
5. **Show Advanced Settings**
6. Set **Internal Storage**: 4GB or more
7. **Finish**
8. Launch new emulator

## Quick Fix (Try This First)
The app is currently trying to install with `--no-uninstall-first` flag. If that doesn't work:

1. **Stop the current build** (Ctrl+C in terminal)
2. **Wipe emulator data** (Solution 1 above)
3. **Run again**: `flutter run -d emulator-5554`

## Current Status
- ✅ App built successfully
- ❌ Installation failed due to storage
- 🔄 Retrying with --no-uninstall-first

## After Fixing Storage
Once storage is fixed, the app should install and you can test:
1. Authentication with PIN: 1607
2. Navigate to My Profile
3. Test Backup feature
