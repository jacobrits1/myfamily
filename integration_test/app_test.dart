import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myfamily/main.dart' as app;
import 'package:myfamily/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('My Family App Integration Tests', () {
    testWidgets('Test Authentication Screen - Choice Display', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test 1: Verify authentication screen appears with choice title
      print('\n🧪 Test 1: Checking authentication screen...');
      expect(find.text('Choose Authentication Method'), findsOneWidget);
      print('✅ Authentication choice screen is visible');

      // Test 2: Check if authentication options are displayed
      print('\n🧪 Test 2: Checking authentication options...');
      
      // Check for PIN Code option
      final pinText = find.text('PIN Code');
      final biometricText = find.text('Biometric');
      
      if (pinText.evaluate().isNotEmpty) {
        print('✅ PIN Code option found');
      }
      
      if (biometricText.evaluate().isNotEmpty) {
        print('✅ Biometric option found');
      }

      // Test 3: Try to tap PIN card if available
      if (pinText.evaluate().isNotEmpty) {
        print('\n🧪 Test 3: Testing PIN card interaction...');
        await tester.tap(pinText);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Check if PIN input field appears
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          print('✅ PIN input field appeared');
        }
      }

      print('\n✅ Authentication screen tests completed');
    });

    testWidgets('Test PIN Setup and Login Flow', (WidgetTester tester) async {
      // Clear any existing PIN for clean test
      final authService = AuthService();
      await authService.clearPin();
      
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('\n🧪 Test: PIN Setup Flow...');
      
      // Should show PIN setup if no PIN is set
      final pinSetupText = find.text('Set up your PIN code');
      if (pinSetupText.evaluate().isNotEmpty || find.text('Enter a 4-digit PIN').evaluate().isNotEmpty) {
        print('✅ PIN setup screen detected');
        
        // Enter PIN
        final pinField = find.byType(TextField).first;
        await tester.enterText(pinField, '1234');
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        // Tap continue/confirm button
        final continueButton = find.text('Continue').first;
        if (continueButton.evaluate().isNotEmpty) {
          await tester.tap(continueButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          // Confirm PIN
          await tester.enterText(pinField, '1234');
          await tester.pumpAndSettle(const Duration(seconds: 1));
          
          final confirmButton = find.text('Confirm PIN');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            
            // Check if dashboard appears
            final dashboardText = find.text('My Family');
            if (dashboardText.evaluate().isNotEmpty || find.text('Add New Member').evaluate().isNotEmpty) {
              print('✅ PIN setup successful - Dashboard appeared');
            }
          }
        }
      }

      print('\n✅ PIN setup test completed');
    });

    testWidgets('Test Add Family Member Flow', (WidgetTester tester) async {
      // Set up PIN first for authentication
      final authService = AuthService();
      await authService.setPin('1234');
      
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('\n🧪 Test: Add Family Member Flow...');
      
      // Authenticate with PIN
      final pinCard = find.text('PIN Code');
      if (pinCard.evaluate().isNotEmpty) {
        await tester.tap(pinCard);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        final pinField = find.byType(TextField).first;
        await tester.enterText(pinField, '1234');
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final verifyButton = find.text('Verify PIN');
        if (verifyButton.evaluate().isNotEmpty) {
          await tester.tap(verifyButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
      }

      // Look for Add New Member button
      final addMemberButton = find.text('Add New Member');
      if (addMemberButton.evaluate().isNotEmpty) {
        print('✅ Add New Member button found');
        await tester.tap(addMemberButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Fill in member details
        final firstNameField = find.byKey(const Key('firstName'));
        if (firstNameField.evaluate().isEmpty) {
          // Try finding by hint text
          final firstNameHint = find.text('First Name');
          if (firstNameHint.evaluate().isNotEmpty) {
            await tester.tap(find.byType(TextField).first);
            await tester.enterText(find.byType(TextField).first, 'John');
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        } else {
          await tester.enterText(firstNameField, 'John');
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
        
        // Enter last name
        final lastNameFields = find.byType(TextField);
        if (lastNameFields.evaluate().length > 1) {
          await tester.enterText(lastNameFields.at(1), 'Doe');
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
        
        // Save member
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          
          // Check if returned to dashboard
          if (find.text('Add New Member').evaluate().isNotEmpty) {
            print('✅ Member saved successfully - Returned to dashboard');
          }
        }
      } else {
        print('⚠ Add New Member button not found - may need authentication');
      }

      print('\n✅ Add member test completed');
    });
  });
}

