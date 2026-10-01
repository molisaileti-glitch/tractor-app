import 'package:flutter/material.dart';

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
  static const _deepGreen = Color(0xFF173B2A);
  static const _fieldGreen = Color(0xFF2F6F4E);
  static const _cream = Color(0xFFFFF8E8);
  static const _deviceName = 'Shamba Bora Mobile';

  final _identifierController = TextEditingController(text: '+255 ');
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
                        obscurePassword: _obscurePassword,
                        isLoading: _sendingOtp,
                        errorText: _loginError,
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
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
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    setState(() => _loginError = null);

    if (password.trim().isEmpty) {
      _challengeId = null;
      _openOtp(identifier.isEmpty ? '+255' : identifier);
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

  void _openOtp(String phoneNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phoneNumber: phoneNumber,
          onBack: () => Navigator.of(context).pop(),
          onVerified: _verifyCode,
        ),
      ),
    );
  }

  Future<bool> _verifyCode(String code) async {
    if (_challengeId != null) {
      try {
        final session = await widget.repository.verifyRemoteOtp(
          challengeId: _challengeId!,
          code: code,
          deviceName: _deviceName,
        );
        if (!mounted) return true;
        _openWorkspaceForSession(session);
        return true;
      } on AuthRemoteException {
        return false;
      }
    }

    final VoidCallback? route = switch (code) {
      '101650' => widget.onOpenOperations,
      '101651' => widget.onOpenOperator,
      '101652' => widget.onOpenFarmer,
      '101653' => widget.onOpenTechnician,
      _ => null,
    };

    if (route == null) return false;

    await widget.repository.signIn(
      phoneOrEmail: _identifierController.text.trim(),
      password: 'otp:$code',
    );
    if (!mounted) return true;
    route();
    return true;
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
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
              'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: _LoginScreenState._deepGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue managing mechanization work.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.62),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Phone number / Email',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: identifierController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                hintText: '+255 7XX XXX XXX or name@union.tz',
                prefixIcon: Icon(Icons.alternate_email_outlined),
              ),
              onSubmitted: (_) => onSendOtp(),
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
            Tooltip(
              message: 'Send OTP',
              child: FilledButton(
                onPressed: isLoading ? null : onSendOtp,
                style: FilledButton.styleFrom(
                  backgroundColor: _LoginScreenState._deepGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
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
        Image.asset(
          'assets/images/tractor.jpeg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.20),
                _LoginScreenState._deepGreen.withValues(alpha: 0.32),
                _LoginScreenState._deepGreen.withValues(alpha: 0.74),
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
            color: _LoginScreenState._cream,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.agriculture,
            color: _LoginScreenState._fieldGreen,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Shamba Bora',
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
      color: const Color(0xFF17201A),
      style: IconButton.styleFrom(backgroundColor: Colors.white),
    );
  }
}
