import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/presentation/app_components.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/remote/auth_remote_data_source.dart';
import '../../data/repositories/auth_local_repository.dart';
import '../../domain/entities/auth_session.dart';
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
  static const _deviceName = 'Kwanza Track Mobile';
  static const _dialCodes = [
    _CountryDialCode(flag: '\u{1F1F9}\u{1F1FF}', country: 'Tanzania', dialCode: '+255'),
    _CountryDialCode(flag: '\u{1F1F0}\u{1F1EA}', country: 'Kenya', dialCode: '+254'),
    _CountryDialCode(flag: '\u{1F1FA}\u{1F1EC}', country: 'Uganda', dialCode: '+256'),
    _CountryDialCode(flag: '\u{1F1F7}\u{1F1FC}', country: 'Rwanda', dialCode: '+250'),
    _CountryDialCode(flag: '\u{1F1E7}\u{1F1EE}', country: 'Burundi', dialCode: '+257'),
  ];

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  _CountryDialCode _selectedDialCode = _dialCodes.first;
  bool _obscurePassword = true;
  bool _sendingOtp = false;
  String? _loginError;
  String? _challengeId;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const _AuthImageBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18, 14, 18, bottomInset + 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BackButton(onPressed: widget.onBack),
                      const SizedBox(height: 86),
                      const _BrandLockup(),
                      const SizedBox(height: 54),
                      _LoginPanel(
                        identifierController: _identifierController,
                        passwordController: _passwordController,
                        selectedDialCode: _selectedDialCode,
                        dialCodes: _dialCodes,
                        obscurePassword: _obscurePassword,
                        isLoading: _sendingOtp,
                        errorText: _loginError,
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onDialCodeChanged: (value) =>
                            setState(() => _selectedDialCode = value),
                        onSendOtp: _sendOtp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    final identifier = _normalizedIdentifier();
    final password = _passwordController.text;
    setState(() => _loginError = null);

    if (identifier.isEmpty) {
      setState(() => _loginError = 'Enter your phone number or email.');
      return;
    }
    if (password.trim().isEmpty) {
      setState(() => _loginError = 'Enter your password to request an OTP.');
      return;
    }

    setState(() => _sendingOtp = true);
    try {
      final challenge = await widget.repository.requestLoginChallenge(
        identifier: identifier,
        password: password,
        deviceName: _deviceName,
      );
      if (!mounted) return;
      _challengeId = challenge.challengeId;
      _openOtp(
        challenge.destination.isEmpty ? identifier : challenge.destination,
      );
    } on AuthRemoteException catch (error) {
      if (!mounted) return;
      setState(() => _loginError = error.message);
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  String _normalizedIdentifier() {
    final raw = _identifierController.text.trim();
    if (raw.isEmpty) return '';
    if (raw.contains('@')) return raw;
    if (raw.startsWith('+')) return raw.replaceAll(RegExp(r'\s+'), '');
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.isEmpty) return '';
    return '${_selectedDialCode.dialCode}$digits';
  }

  void _openOtp(String phoneNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phoneNumber: phoneNumber,
          onBack: () => Navigator.of(context).pop(),
          onVerified: _verifyCode,
          onResend: _resendCode,
        ),
      ),
    );
  }

  Future<String?> _verifyCode(String code) async {
    final challengeId = _challengeId;
    if (challengeId == null) {
      return 'Your OTP session expired. Please request a new code.';
    }

    try {
      final session = await widget.repository.verifyRemoteOtp(
        challengeId: challengeId,
        code: code,
        deviceName: _deviceName,
      );
      if (!mounted) return null;
      _openWorkspaceForSession(session);
      return null;
    } on AuthRemoteException catch (error) {
      return error.message;
    }
  }

  Future<String?> _resendCode() async {
    final challengeId = _challengeId;
    if (challengeId == null) return null;

    try {
      final challenge = await widget.repository.resendRemoteOtp(
        challengeId: challengeId,
      );
      if (challenge.challengeId.isNotEmpty) {
        _challengeId = challenge.challengeId;
      }
      return null;
    } on AuthRemoteException catch (error) {
      return error.message;
    }
  }

  void _openWorkspaceForSession(AuthSession session) {
    final role = session.role?.toLowerCase() ?? '';
    final permissions = session.permissions;
    final managesMechanization = permissions.any(
      (permission) =>
          permission == 'mech.requests.manage' ||
          permission == 'mech.jobs.manage' ||
          permission == 'mech.override' ||
          permission == 'mech.exceptions.manage' ||
          permission == 'mech.registry.manage',
    );

    if (managesMechanization ||
        role.contains('dispatcher') ||
        role.contains('officer') ||
        role.contains('manager') ||
        role.contains('owner')) {
      widget.onOpenOperations();
      return;
    }
    if (role.contains('operator') || permissions.contains('mech.operate')) {
      widget.onOpenOperator();
      return;
    }
    if (role.contains('technician')) {
      widget.onOpenTechnician();
      return;
    }
    if (role.contains('farmer')) {
      widget.onOpenFarmer();
      return;
    }
    widget.onOpenOperations();
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.identifierController,
    required this.passwordController,
    required this.selectedDialCode,
    required this.dialCodes,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorText,
    required this.onTogglePassword,
    required this.onDialCodeChanged,
    required this.onSendOtp,
  });

  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final _CountryDialCode selectedDialCode;
  final List<_CountryDialCode> dialCodes;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTogglePassword;
  final ValueChanged<_CountryDialCode> onDialCodeChanged;
  final Future<void> Function() onSendOtp;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.54)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Center(
              child: Text(
                'Login',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Your Phone Number',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We will use this number to verify your identity and send secure work notifications.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.62),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Phone Number / Email',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _PhoneIdentityPicker(
              controller: identifierController,
              selectedDialCode: selectedDialCode,
              dialCodes: dialCodes,
              onDialCodeChanged: onDialCodeChanged,
              onSubmitted: (_) => onSendOtp(),
            ),
            const SizedBox(height: 8),
            Text(
              'This number will be used for OTP verification and account notifications.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'Password',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: const TextStyle(fontWeight: FontWeight.w400),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              onSubmitted: (_) => onSendOtp(),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 22),
            AppGlowButton(
              onPressed: onSendOtp,
              loading: isLoading,
              label: 'Continue',
              trailing: Icons.arrow_forward,
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthImageBackground extends StatelessWidget {
  const _AuthImageBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Transform.scale(
            scale: 1.04,
            child: Image.asset(
              'assets/images/tractor.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.20),
                AppColors.deepGreen.withValues(alpha: 0.32),
                AppColors.deepGreen.withValues(alpha: 0.74),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.agriculture,
            color: AppColors.fieldGreen,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Kwanza Track',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      color: AppColors.text,
      style: IconButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}

class _PhoneIdentityPicker extends StatelessWidget {
  const _PhoneIdentityPicker({
    required this.controller,
    required this.selectedDialCode,
    required this.dialCodes,
    required this.onDialCodeChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final _CountryDialCode selectedDialCode;
  final List<_CountryDialCode> dialCodes;
  final ValueChanged<_CountryDialCode> onDialCodeChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: PopupMenuButton<_CountryDialCode>(
              tooltip: 'Country code',
              initialValue: selectedDialCode,
              onSelected: onDialCodeChanged,
              itemBuilder: (context) => [
                for (final code in dialCodes)
                  PopupMenuItem(
                    value: code,
                    child: Text(
                      '${code.flag} ${code.country} ${code.dialCode}',
                    ),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      selectedDialCode.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedDialCode.dialCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black.withValues(alpha: 0.54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 58,
            child: VerticalDivider(
              width: 1,
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: '7XX XXX XXX or email',
                hintStyle: TextStyle(fontWeight: FontWeight.w400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryDialCode {
  const _CountryDialCode({
    required this.flag,
    required this.country,
    required this.dialCode,
  });

  final String flag;
  final String country;
  final String dialCode;
}
