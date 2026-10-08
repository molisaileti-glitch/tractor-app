import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/components/components.dart';
import '../../../../core/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onVerified,
    required this.onResend,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final Future<String?> Function(String code) onVerified;
  final Future<String?> Function() onResend;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _verifying = false;
  bool _resending = false;
  String? _errorText;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
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
          const _OtpImageBackground(),
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
                      _OtpPanel(
                        phoneNumber: widget.phoneNumber,
                        errorText: _errorText,
                        verifying: _verifying,
                        resending: _resending,
                        otpBoxBuilder: _otpBox,
                        onVerify: _verify,
                        onResend: _resend,
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

  Widget _otpBox({required int index}) {
    return TextField(
      key: ValueKey('otp-digit-$index'),
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      style: const TextStyle(
        color: AppColors.deepGreen,
        fontWeight: FontWeight.w900,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        filled: true,
        fillColor: const Color(0xFFF4F5F3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fieldGreen, width: 1.5),
        ),
      ),
      onChanged: (value) {
        setState(() => _errorText = null);
        if (value.isNotEmpty && index < _focusNodes.length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
        if (value.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      },
    );
  }

  Future<void> _verify() async {
    final code = _controllers.map((controller) => controller.text).join();
    if (code.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit OTP code.');
      return;
    }

    setState(() => _verifying = true);
    final error = await widget.onVerified(code);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _verifying = false;
        _errorText = error;
      });
      return;
    }
    await showAppSuccessDialog(
      context,
      title: 'Verified',
      message: 'Your OTP was verified successfully.',
      buttonLabel: 'Continue',
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() {
      _resending = true;
      _errorText = null;
    });
    final error = await widget.onResend();
    if (!mounted) return;
    setState(() {
      _resending = false;
      _errorText = error;
    });
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new verification code was sent.')),
      );
    }
  }
}

class _OtpPanel extends StatelessWidget {
  const _OtpPanel({
    required this.phoneNumber,
    required this.errorText,
    required this.verifying,
    required this.resending,
    required this.otpBoxBuilder,
    required this.onVerify,
    required this.onResend,
  });

  final String phoneNumber;
  final String? errorText;
  final bool verifying;
  final bool resending;
  final Widget Function({required int index}) otpBoxBuilder;
  final VoidCallback onVerify;
  final VoidCallback onResend;

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
                    'OTP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Enter the 6-digit code sent to your phone',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepGreen,
                    height: 1.10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification code to $phoneNumber.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.62),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    for (var index = 0; index < 6; index++) ...[
                      Expanded(child: otpBoxBuilder(index: index)),
                      if (index != 5) const SizedBox(width: 8),
                    ],
                  ],
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                AppGlowButton(
                  onPressed: onVerify,
                  loading: verifying,
                  label: verifying ? 'Verifying...' : 'Continue',
                  trailing: Icons.arrow_forward,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: resending || verifying ? null : onResend,
                  child: Text(resending ? 'Sending...' : 'Resend code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpImageBackground extends StatelessWidget {
  const _OtpImageBackground();

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
