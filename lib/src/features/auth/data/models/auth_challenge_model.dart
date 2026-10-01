class AuthChallengeModel {
  const AuthChallengeModel({
    required this.challengeId,
    required this.channel,
    required this.destination,
    required this.otpRequired,
    required this.resendAfterSeconds,
    required this.expiresInSeconds,
  });

  factory AuthChallengeModel.fromJson(Map<String, Object?> json) {
    return AuthChallengeModel(
      challengeId: json['challenge_id']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'sms',
      destination: json['destination']?.toString() ?? '',
      otpRequired: json['otp_required'] as bool? ?? true,
      resendAfterSeconds: _asInt(json['resend_after_s']),
      expiresInSeconds: _asInt(json['expires_in_s']),
    );
  }

  final String challengeId;
  final String channel;
  final String destination;
  final bool otpRequired;
  final int? resendAfterSeconds;
  final int? expiresInSeconds;

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
