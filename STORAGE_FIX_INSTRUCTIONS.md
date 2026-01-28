# Fix Emulator Storage Issue - Step by Step

## Current Problem
The emulator `emulator-5554` doesn't have enough storage to install the app.

## Immediate Solution

### Option 1: Wipe Emulator Data (Fastest - 2 minutes)

1. **Close the emulator** (click X or stop it)
2. **Open Android Studio**
3. **Go to:** Tools → Device Manager (or View → Tool Windows → Device Manager)
4. **Find:** "Medium Phone API 35" in the list
5. **Click the dropdown arrow (▼)** next to the emulator
6. **Select:** "Wipe Data"
7. **Confirm** the wipe
8. **Start the emulator** again (click Play button)
9. **Wait** for emulator to fully boot
10. **Run:** `flutter run -d emulator-5554`

### Option 2: Use Different Emulator

Try a different emulator that might have more space:

```bash
# Stop current emulator
# Then launch a different one:
flutter emulators --launch Medium_Phone_API_35_2
# Wait for it to boot, then:
flutter run -d <new-emulator-id>
```

### Option 3: Increase Storage (If Option 1 doesn't work)

1. **Android Studio** → Device Manager
2. **Click Edit (pencil icon)** on "Medium Phone API 35"
3. **Click "Show Advanced Settings"**
4. **Find "Internal Storage"** section
5. **Change from 2GB to 4GB** (or more)
6. **Click "Finish"**
7. **Wipe Data** (as in Option 1)
8. **Restart emulator**
9. **Run:** `flutter run -d emulator-5554`

## Testing on Chrome First

While fixing the emulator, I'm testing on Chrome. Note:
- ⚠️ SQLite doesn't work on web, so backup feature will be limited
- ✅ UI can still be tested
- ✅ Navigation can be tested

## After Storage is Fixed

Once the emulator has space:
1. App will install successfully
2. Authenticate with PIN: `1607`
3. Navigate to My Profile
4. Test Backup feature

## Quick Command Reference

```bash
# Check devices
flutter devices

# Launch different emulator
flutter emulators --launch Medium_Phone_API_35_2

# Run on emulator
flutter run -d emulator-5554

# Run on Chrome (for UI testing)
flutter run -d chrome
```
