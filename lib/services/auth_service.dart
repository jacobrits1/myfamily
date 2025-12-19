import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Authentication service for biometric and PIN authentication
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _pinKey = 'user_pin';

  // Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Check available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      // Check if device supports biometrics
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      // Check if biometrics are available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      // Authenticate
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your family information',
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow fallback to device credentials
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException {
      // Handle platform exceptions
      return false;
    } catch (_) {
      return false;
    }
  }

  // Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      final pin = await _secureStorage.read(key: _pinKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Set PIN code
  Future<bool> setPin(String pin) async {
    try {
      if (pin.length < 4) {
        return false;
      }
      await _secureStorage.write(key: _pinKey, value: pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify PIN code
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return storedPin == pin;
    } catch (e) {
      return false;
    }
  }

  // Clear PIN (for testing/reset)
  Future<void> clearPin() async {
    try {
      await _secureStorage.delete(key: _pinKey);
    } catch (e) {
      // Ignore errors
    }
  }

  // Stop authentication (if needed)
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }
}
