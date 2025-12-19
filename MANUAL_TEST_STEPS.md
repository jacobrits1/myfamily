# Manual Test Steps - Login and Add Person

## 🧪 Test Scenario 1: Login/Authentication

### Steps:
1. **Launch App**
   - App should open to authentication screen
   - Should see "Choose Authentication Method" title

2. **Test PIN Login (if PIN is set)**
   - Tap "PIN Code" card
   - Enter 4-digit PIN
   - Should authenticate and show dashboard

3. **Test Biometric Login (if available)**
   - Tap "Biometric" card
   - Complete biometric authentication
   - Should authenticate and show dashboard

4. **Test First Time Setup**
   - If no PIN is set, should show PIN setup screen
   - Enter PIN (e.g., "1234")
   - Confirm PIN (e.g., "1234")
   - Should authenticate and show dashboard

## 🧪 Test Scenario 2: Add Family Member

### Steps:
1. **Navigate to Add Member**
   - From dashboard, tap "Add New Member" card (large teal card at top)
   - OR tap floating action button (+ icon)

2. **Fill in Member Information**
   - First Name: "John"
   - Last Name: "Doe"
   - Date of Birth: "01/01/1990" (optional)
   - Phone: "555-1234" (optional)
   - Email: "john.doe@example.com" (optional)
   - Address: "123 Main St" (optional)
   - City: "New York" (optional)
   - State: "NY" (optional)
   - ZIP Code: "10001" (optional)
   - SSN: "123-45-6789" (optional)
   - Student ID: "STU123" (optional)

3. **Add Profile Photo (Optional)**
   - Tap profile photo circle
   - Choose "Camera" or "Gallery"
   - Select/take a photo
   - Photo should appear in circle

4. **Save Member**
   - Tap "Save" button (top right)
   - Should return to dashboard
   - New member should appear in the list

5. **Verify Member Added**
   - Check dashboard shows new member card
   - Card should display name and photo (if added)
   - Tap card to view member details

## ✅ Expected Results

### Authentication:
- ✅ Choice screen appears on launch
- ✅ PIN authentication works
- ✅ Biometric authentication works (if available)
- ✅ Dashboard appears after successful authentication

### Add Member:
- ✅ Add member screen opens
- ✅ Form fields accept input
- ✅ Profile photo can be added
- ✅ Member saves successfully
- ✅ Member appears on dashboard
- ✅ Member details can be viewed

## 🐛 Common Issues to Check

1. **Authentication Issues:**
   - PIN not saving correctly
   - Biometric not working
   - Choice screen not showing

2. **Add Member Issues:**
   - Form validation errors
   - Photo not saving
   - Member not appearing in list
   - Database errors

## 📝 Test Notes

- Test with both PIN and biometric (if available)
- Test adding member with minimal info (just name)
- Test adding member with all fields filled
- Test adding member with profile photo
- Verify data persists after app restart

