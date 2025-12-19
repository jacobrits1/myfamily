# Logo Integration Plan

## Logo Description
The provided logo features:
- Two human figures (male in blue/teal, female in orange) representing family
- A tree structure with trunk in orange
- Canopy made of digital file/folder icons in orange
- Perfect representation of "family information management"

## Integration Steps

### 1. Add Logo Assets
- Place logo file in `assets/images/` directory
- Update `pubspec.yaml` to include assets
- Create different sizes for app icon and splash screen

### 2. Update App Icon
- Replace default Flutter launcher icon with the logo
- Generate app icons for all platforms (Android, iOS)

### 3. Update Splash Screen
- Use logo in authentication screen
- Create branded splash screen

### 4. Update App Theme
- Match app colors to logo colors:
  - Orange: #F97316 (already using as secondary)
  - Blue/Teal: #0891B2 (already using as primary)
  - White background

### 5. Dashboard Branding
- Add logo to dashboard header
- Use as app icon in navigation

## Files to Update
1. `pubspec.yaml` - Add assets section
2. `lib/main.dart` - Update app theme colors
3. `lib/screens/auth_screen.dart` - Add logo to authentication screen
4. `lib/screens/dashboard_screen.dart` - Add logo to header
5. Android/iOS app icons - Replace with logo

