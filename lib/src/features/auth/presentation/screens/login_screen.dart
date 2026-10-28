import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../components/components.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
  static const _deviceName = 'SB Mechanization Mobile';
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _sendingOtp = false;
  String? _loginError;
  String? _challengeId;
  late final Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const SizedBox(height: 58),
                  _BrandLockup(packageInfo: _packageInfo),
                  const SizedBox(height: 34),
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
    if (permissions.contains('mech.view')) {
      widget.onOpenOperations();
      return;
    }
    unawaited(_rejectUnsupportedSession());
  }

  Future<void> _rejectUnsupportedSession() async {
    await widget.repository.signOut();
    if (!mounted) return;
    setState(() {
      _loginError =
          'This account does not have access to a supported SB Mechanization mobile workspace.';
    });
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
    final strings = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.welcomeBack,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveText(context),
            height: 1.08,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.signInToContinue,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.adaptiveMutedText(context),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: identifierController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: strings.phoneOrEmail,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: strings.enterPassword,
            hintStyle: const TextStyle(fontWeight: FontWeight.w400),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip: obscurePassword
                  ? strings.showPassword
                  : strings.hidePassword,
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
          label: strings.sendOtp,
          trailing: Icons.arrow_forward,
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.packageInfo});

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Image.asset(
                'assets/images/tractor_launcher_icon.png',
                fit: BoxFit.contain,
                semanticLabel: strings.appLogoSemantics,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            context.appText('SB Mechanization'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.mechanizationOperations,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: packageInfo,
            builder: (context, snapshot) {
              final info = snapshot.data;
              if (info == null) return const SizedBox(height: 18);
              final build = info.buildNumber.trim();
              final value = build.isEmpty
                  ? info.version
                  : '${info.version} ($build)';
              return Text(
                strings.appVersion(value),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: strings.back,
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back),
      color: AppColors.adaptiveText(context),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
