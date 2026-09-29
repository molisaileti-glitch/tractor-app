import 'package:flutter/material.dart';

import '../../data/repositories/auth_local_repository.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.repository,
    required this.onBack,
    required this.onOpenFarmer,
    required this.onOpenOperations,
    required this.onOpenOperator,
    required this.onOpenTechnician,
    required this.onCreateFarmerAccount,
  });

  final AuthLocalRepository repository;
  final VoidCallback onBack;
  final VoidCallback onOpenFarmer;
  final VoidCallback onOpenOperations;
  final VoidCallback onOpenOperator;
  final VoidCallback onOpenTechnician;
  final VoidCallback onCreateFarmerAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _deepGreen = Color(0xFF173B2A);
  static const _fieldGreen = Color(0xFF2F6F4E);

  final _phoneController = TextEditingController(text: '+255 ');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepGreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFFFFF8E8),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFFFFF8E8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access tractor requests, GPS-verified jobs, and offline farm records.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFFFF8E8).withValues(alpha: 0.82),
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAF7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _deepGreen.withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: _deepGreen,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Phone number',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _deepGreen,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              color: _deepGreen,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              hintText: '+255 7XX XXX XXX',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              suffixIcon: IconButton(
                                tooltip: 'Send OTP',
                                onPressed: _sendOtp,
                                icon: const Icon(Icons.arrow_forward),
                                color: const Color(0xFFFFF8E8),
                                style: IconButton.styleFrom(
                                  backgroundColor: _fieldGreen,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _sendOtp(),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'We will send a one-time code to confirm this phone number.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _deepGreen.withValues(alpha: 0.64),
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phoneNumber: phone.isEmpty ? '+255' : phone,
          onBack: () => Navigator.of(context).pop(),
          onVerified: _verifyCode,
        ),
      ),
    );
  }

  Future<bool> _verifyCode(String code) async {
    final VoidCallback? route = switch (code) {
      '101650' => widget.onOpenOperations,
      '101651' => widget.onOpenOperator,
      '101652' => widget.onOpenFarmer,
      '101653' => widget.onOpenTechnician,
      _ => null,
    };

    if (route == null) return false;

    await widget.repository.signIn(
      phoneOrEmail: _phoneController.text.trim(),
      password: 'otp:$code',
    );
    if (!mounted) return true;
    route();
    return true;
  }
}
