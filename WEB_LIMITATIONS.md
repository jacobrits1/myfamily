# Web Platform Limitations

## ⚠️ Important Note

This Flutter app is **designed for mobile platforms (Android/iOS)** and has **limited web support** due to mobile-specific dependencies.

## 🚫 Features That Won't Work on Web

### 1. **SQLite Database (sqflite)**
- **Status:** ❌ Not supported on web
- **Impact:** No database storage, family members cannot be saved/retrieved
- **Alternative:** Would need to use web-compatible storage (IndexedDB, SharedPreferences web, etc.)

### 2. **Biometric Authentication (local_auth)**
- **Status:** ❌ Not supported on web
- **Impact:** No fingerprint/face recognition authentication
- **Alternative:** Would need web-based authentication (WebAuthn API)

### 3. **File System Access (path_provider)**
- **Status:** ⚠️ Limited support
- **Impact:** Document storage paths may not work correctly
- **Alternative:** Use browser's file system access API or IndexedDB

### 4. **Image Picker (image_picker)**
- **Status:** ⚠️ Limited support (uses file input)
- **Impact:** Camera access may not work, gallery access is limited
- **Alternative:** Uses HTML file input, no direct camera access

### 5. **File Picker (file_picker)**
- **Status:** ✅ Has web support
- **Impact:** Should work but with browser limitations
- **Note:** Uses browser's file picker dialog

### 6. **Google ML Kit (google_mlkit_text_recognition)**
- **Status:** ❌ Not supported on web
- **Impact:** OCR functionality won't work
- **Alternative:** Would need web-based OCR (Tesseract.js, etc.)

### 7. **Android Autofill Service**
- **Status:** ❌ Not applicable on web
- **Impact:** Autofill functionality is Android-specific

## ✅ What Might Work on Web

- **UI Components:** Basic Flutter UI should render
- **Navigation:** Screen navigation should work
- **Forms:** Text input forms should work
- **File Picker:** Basic file selection (limited)

## 🔧 To Make Web-Compatible

To make this app work on web, you would need to:

1. **Replace SQLite:**
   - Use `sqflite_common_ffi` with IndexedDB adapter
   - Or use `shared_preferences` for simple data
   - Or use a backend database

2. **Replace Authentication:**
   - Use WebAuthn API for biometric-like authentication
   - Or use password-based authentication
   - Or use OAuth providers

3. **Replace File Storage:**
   - Use IndexedDB for document storage
   - Use browser's File System Access API
   - Or use cloud storage

4. **Replace OCR:**
   - Use Tesseract.js for web-based OCR
   - Or use cloud OCR services

5. **Conditional Imports:**
   - Use `kIsWeb` checks to conditionally import packages
   - Create platform-specific implementations

## 📝 Current Status

**Web Build:** ⚠️ Will likely fail or have limited functionality

**Recommended:** Use Android emulator or iOS simulator for full functionality testing.

## 🎯 Testing Recommendation

For testing this app, use:
- ✅ **Android Emulator** (recommended)
- ✅ **iOS Simulator**
- ❌ **Web Browser** (not recommended - limited functionality)


