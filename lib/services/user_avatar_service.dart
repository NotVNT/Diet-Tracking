import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'firestore_service.dart';

/// Lightweight service to provide the current user's avatar image
/// - Loads once from Firestore and caches in memory
/// - Provides an ImageProvider fallback by gender if no avatar URL
/// - Decouples Chat UI from Profile feature for easier maintenance
class UserAvatarService {
  UserAvatarService._internal();
  static final UserAvatarService instance = UserAvatarService._internal();

  String? _avatarUrl;
  GenderType? _gender;
  bool _loaded = false;

  /// Preload user avatar and gender once per app session.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final data = await FirestoreService().getCurrentUserData();
      _avatarUrl = (data?['avatars'] as String?)?.trim();
      final genderRaw = data?['gender'] as String?;
      _gender = _parseGender(genderRaw);

      // Fallback to FirebaseAuth photoURL if Firestore has no avatar
      _avatarUrl ??= FirebaseAuth.instance.currentUser?.photoURL;
    } catch (_) {
      // ignore errors – fallbacks will be used
    } finally {
      _loaded = true;
    }
  }

  /// Returns a cached avatar URL, if available.
  String? get cachedAvatarUrl => _avatarUrl;

  /// Update cache when user changes avatar elsewhere (optional use).
  void updateAvatarUrl(String? url) {
    _avatarUrl = url?.trim();
  }

  /// Get an ImageProvider for the user avatar with graceful fallbacks.
  ImageProvider<Object> get imageProvider {
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return NetworkImage(_avatarUrl!);
    }
    if (_gender == GenderType.female) {
      return const AssetImage('assets/gender/women.jpg');
    }
    return const AssetImage('assets/gender/men.jpg');
  }

  GenderType? _parseGender(String? value) {
    if (value == null) return null;
    try {
      return GenderType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return GenderType.other;
    }
  }
}

