import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

// Biometric and PIN authentication screen
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticating = false;
  bool _isSettingPin = false;
  bool _showPinInput = false;
  bool _hasBiometrics = false;
  bool _hasPin = false;
  String _errorMessage = '';
  String _confirmPin = '';

  @override
  void initState() {
    super.initState();
    _checkAuthOptions();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // Check authentication options
  Future<void> _checkAuthOptions() async {
    final isSupported = await _authService.isDeviceSupported();
    final isPinSet = await _authService.isPinSet();

    if (mounted) {
      setState(() {
        _hasBiometrics = isSupported;
        _hasPin = isPinSet;
        
        if (!isSupported && !isPinSet) {
          // No biometrics and no PIN - show PIN setup
          _showPinInput = true;
          _isSettingPin = true;
        }
        // Otherwise show choice screen - user will choose
      });
    }
  }

  // Authenticate user with biometrics
  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    final authenticated = await _authService.authenticate();

    if (authenticated) {
      widget.onAuthenticated();
    } else {
      setState(() {
        _isAuthenticating = false;
        // Show PIN option if biometric fails
        if (!_showPinInput) {
          _showPinInput = true;
        }
      });
    }
  }

  // Handle PIN authentication
  Future<void> _handlePinAuth() async {
    final pin = _pinController.text;

    if (_isSettingPin) {
      // Setting up PIN for first time
      if (pin.length < 4) {
        setState(() {
          _errorMessage = 'PIN must be at least 4 digits';
        });
        return;
      }

      if (_confirmPin.isEmpty) {
        // First PIN entry - ask for confirmation
        setState(() {
          _confirmPin = pin;
          _pinController.clear();
          _errorMessage = '';
        });
        return;
      }

      // Verify PINs match
      if (pin != _confirmPin) {
        setState(() {
          _errorMessage = 'PINs do not match. Please try again.';
          _confirmPin = '';
          _pinController.clear();
        });
        return;
      }

      // Save PIN
      final success = await _authService.setPin(pin);
      if (success) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Failed to set PIN. Please try again.';
          _confirmPin = '';
          _pinController.clear();
        });
      }
    } else {
      // Verifying PIN
      if (pin.length < 4) {
        setState(() {
          _errorMessage = 'Please enter your 4-digit PIN';
        });
        return;
      }

      final isValid = await _authService.verifyPin(pin);
      if (isValid) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
          _pinController.clear();
        });
      }
    }
  }

  // Switch to PIN input
  void _switchToPin() {
    setState(() {
      _showPinInput = true;
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon/logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryColor),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.family_restroom,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                
                // App title
                const Text(
                  'My Family',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textColor),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  _isSettingPin && _confirmPin.isEmpty
                      ? 'Set up your PIN code'
                      : _isSettingPin && _confirmPin.isNotEmpty
                          ? 'Confirm your PIN code'
                          : 'Secure Family Information Manager',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // PIN Input Section
                if (_showPinInput) ...[
                  Text(
                    _isSettingPin && _confirmPin.isEmpty
                        ? 'Enter a 4-digit PIN'
                        : _isSettingPin && _confirmPin.isNotEmpty
                            ? 'Re-enter your PIN to confirm'
                            : 'Enter your PIN',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: '',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(AppConstants.primaryColor),
                            width: 2,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _handlePinAuth(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handlePinAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isSettingPin && _confirmPin.isEmpty
                          ? 'Continue'
                          : _isSettingPin && _confirmPin.isNotEmpty
                              ? 'Confirm PIN'
                              : 'Verify PIN',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Authentication Choice Section
                  if (_isAuthenticating)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(AppConstants.primaryColor)),
                    )
                  else
                    Column(
                      children: [
                        const Text(
                          'Choose Authentication Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.textColor),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Biometric Option
                        if (_hasBiometrics)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: _authenticate,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(AppConstants.primaryColor).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.fingerprint,
                                        size: 32,
                                        color: Color(AppConstants.primaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Biometric',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(AppConstants.textColor),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Use fingerprint or face recognition',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        
                        if (_hasBiometrics && _hasPin) const SizedBox(height: 16),
                        
                        // PIN Option
                        if (_hasPin)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: _switchToPin,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(AppConstants.secondaryColor).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock,
                                        size: 32,
                                        color: Color(AppConstants.secondaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PIN Code',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(AppConstants.textColor),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Enter your 4-digit PIN',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
                
                // Error message
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
