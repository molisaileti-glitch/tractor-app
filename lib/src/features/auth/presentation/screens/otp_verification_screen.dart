import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onVerified,
  });

  final String phoneNumber;
  final VoidCallback onBack;
  final Future<bool> Function(String code) onVerified;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _deepGreen = Color(0xFF173B2A);
  static const _fieldGreen = Color(0xFF2F6F4E);

  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _verifying = false;
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE6E8E3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: _deepGreen,
                  ),
                  const Spacer(),
                  Text(
                    'Verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _deepGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 40),
                            Expanded(
                              child: Text(
                                'OTP Verification',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: _deepGreen,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: widget.onBack,
                              icon: const Icon(Icons.close),
                              color: _deepGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Enter the 6-digit code sent to ${widget.phoneNumber}.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _deepGreen.withValues(alpha: 0.64),
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            for (var index = 0; index < 6; index++) ...[
                              Expanded(child: _otpBox(index: index)),
                              if (index != 5) const SizedBox(width: 8),
                            ],
                          ],
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Did not receive the code?',
                              style: TextStyle(
                                color: _deepGreen.withValues(alpha: 0.62),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Resend'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _verifying ? null : _verify,
                          style: FilledButton.styleFrom(
                            backgroundColor: _fieldGreen,
                            foregroundColor: const Color(0xFFFFF8E8),
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(_verifying ? 'Verifying...' : 'Verify'),
                        ),
                      ],
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
        color: _deepGreen,
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
      decoration: InputDecoration(
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        filled: true,
        fillColor: const Color(0xFFF6F8F4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _deepGreen.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _fieldGreen, width: 1.5),
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
    final accepted = await widget.onVerified(code);
    if (!mounted) return;
    if (!accepted) {
      setState(() {
        _verifying = false;
        _errorText = 'Invalid code. Use the code assigned to your role.';
      });
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
