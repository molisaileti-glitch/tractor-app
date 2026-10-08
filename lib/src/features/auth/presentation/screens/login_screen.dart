import 'package:flutter/material.dart';

import '../../../../core/presentation/components/components.dart';
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
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 14, 24, bottomInset + 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackButton(onPressed: widget.onBack),
                  const SizedBox(height: 88),
                  const _BrandLockup(),
                  const SizedBox(height: 42),
                  _LoginPanel(
                    identifierController: _identifierController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    isLoading: _sendingOtp,
                    errorText: _loginError,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSendOtp: _sendOtp,
                  ),
                ],
              ),
            ),
          ),
        ),
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
    if (digits.startsWith('255') ||
        digits.startsWith('254') ||
        digits.startsWith('256') ||
        digits.startsWith('250') ||
        digits.startsWith('257')) {
      return '+$digits';
    }
    return '+255$digits';
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
    required this.obscurePassword,
    required this.isLoading,
    required this.errorText,
    required this.onTogglePassword,
    required this.onSendOtp,
  });

  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSendOtp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black.withValues(alpha: 0.62),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: identifierController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Phone number or email',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: const TextStyle(fontWeight: FontWeight.w400),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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
          label: 'Sign In',
          trailing: Icons.arrow_forward,
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
            color: AppColors.fieldGreen.withValues(alpha: 0.10),
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
            color: AppColors.text,
            fontWeight: FontWeight.w700,
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
