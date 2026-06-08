import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AppAuthProviderData {
  const AppAuthProviderData({required this.providerId});

  final String providerId;
}

class AppAuthUser {
  AppAuthUser({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.photoURL,
    required this.emailVerified,
    required this.providerData,
    required String? Function() tokenProvider,
    required Future<void> Function() reloadProvider,
  }) : _tokenProvider = tokenProvider,
       _reloadProvider = reloadProvider;

  factory AppAuthUser.fromSupabaseUser(
    supabase.User user,
    supabase.Session? session,
    Future<void> Function() reloadProvider,
  ) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user.appMetadata;
    final providers = <String>{
      if (appMetadata['provider'] is String)
        ..._providerAliases(appMetadata['provider'] as String),
      if (appMetadata['providers'] is List)
        ...(appMetadata['providers'] as List)
            .whereType<String>()
            .expand(_providerAliases),
    };

    return AppAuthUser(
      uid: user.id,
      email: user.email,
      phoneNumber: user.phone,
      displayName:
          metadata['full_name'] as String? ??
          metadata['name'] as String? ??
          metadata['display_name'] as String?,
      photoURL:
          metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
      emailVerified: user.emailConfirmedAt != null,
      providerData: providers
          .map((provider) => AppAuthProviderData(providerId: provider))
          .toList(),
      tokenProvider: () => session?.accessToken,
      reloadProvider: reloadProvider,
    );
  }

  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final List<AppAuthProviderData> providerData;
  final String? Function() _tokenProvider;
  final Future<void> Function() _reloadProvider;

  Future<String?> getIdToken([bool forceRefresh = false]) async {
    if (forceRefresh) {
      await reload();
    }
    return _tokenProvider();
  }

  Future<void> reload() => _reloadProvider();

  static List<String> _providerAliases(String provider) {
    return switch (provider) {
      'google' => ['google', 'google.com'],
      'apple' => ['apple', 'apple.com'],
      _ => [provider],
    };
  }
}

class AppAuthCredential {
  const AppAuthCredential({required this.user});

  final AppAuthUser? user;
}

class AppPhoneAuthCredential {
  const AppPhoneAuthCredential({
    required this.verificationId,
    required this.smsCode,
  });

  final String verificationId;
  final String smsCode;
}
