import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/errors/app_exception.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedUid = prefs.getString('cached_session_uid');
        if (cachedUid != null &&
            cachedUid.isNotEmpty &&
            state.userProfile == null) {
          final cachedProfile = UserProfileModel(
            uid: cachedUid,
            email: prefs.getString('cached_session_email') ?? '',
            fullName: prefs.getString('cached_session_name') ?? 'User',
            phoneNumber: prefs.getString('cached_session_phone') ?? '',
            role: prefs.getString('cached_session_role') ?? 'customer',
            garageId: prefs.getString('cached_session_garage_id'),
            avatarUrl: prefs.getString('cached_session_avatar'),
            createdAt: DateTime.now(),
          );
          state = state.copyWith(
            isLoading: false,
            isInitialized: true,
            userProfile: cachedProfile,
            activeExperience: cachedProfile.role == 'merchant'
                ? 'merchant'
                : 'customer',
          );
        }
      } catch (_) {}

      try {
        if (!FirebaseConfig.isInitialized) {
          await FirebaseConfig.initialize();
        }
        final currentFirebaseUser = FirebaseAuth.instance.currentUser;
        if (currentFirebaseUser != null) {
          await _restoreExistingSession(currentFirebaseUser);
        } else {
          state = state.copyWith(isLoading: false, isInitialized: true);
        }
      } catch (_) {
        state = state.copyWith(isLoading: false, isInitialized: true);
      }
    });

    return const AuthState(isLoading: true, isInitialized: false);
  }

  Future<void> _persistSession(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_session_uid', profile.uid);
      await prefs.setString('cached_session_email', profile.email);
      await prefs.setString('cached_session_name', profile.fullName);
      await prefs.setString('cached_session_role', profile.role);
      await prefs.setString('cached_session_phone', profile.phoneNumber);
      if (profile.garageId != null && profile.garageId!.isNotEmpty) {
        await prefs.setString('cached_session_garage_id', profile.garageId!);
      } else {
        await prefs.remove('cached_session_garage_id');
      }
      if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
        await prefs.setString('cached_session_avatar', profile.avatarUrl!);
      }
    } catch (_) {}
  }

  Future<void> _restoreExistingSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAvatar =
          prefs.getString('user_avatar_${user.uid}') ??
          prefs.getString('cached_session_avatar');

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 2));
      if (doc.exists && doc.data() != null) {
        var profile = UserProfileModel.fromFirestore(doc.data()!, user.uid);
        if (profile.avatarUrl == null && cachedAvatar != null) {
          profile = profile.copyWith(avatarUrl: cachedAvatar);
        } else if (profile.avatarUrl == null && user.photoURL != null) {
          profile = profile.copyWith(avatarUrl: user.photoURL);
        }
        await _persistSession(profile);

        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          userProfile: profile,
          activeExperience: profile.role == 'merchant'
              ? 'merchant'
              : 'customer',
        );
        return;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final cachedUid = prefs.getString('cached_session_uid');
    final cachedEmail = prefs.getString('cached_session_email');
    final cachedName = prefs.getString('cached_session_name');
    final cachedRole = prefs.getString('cached_session_role');
    final cachedPhone = prefs.getString('cached_session_phone');
    final cachedGarageId = prefs.getString('cached_session_garage_id');
    final cachedAvatar =
        prefs.getString('cached_session_avatar') ?? user.photoURL;

    final isVishnu =
        user.email?.toLowerCase() == 'vishnushaji431@gmail.com' ||
        user.email?.toLowerCase() == '318@gmail.com';

    final fallbackProfile = UserProfileModel(
      uid: user.uid.isNotEmpty ? user.uid : (cachedUid ?? 'user_fallback'),
      email: user.email ?? (cachedEmail ?? 'user@garagecard.app'),
      fullName:
          cachedName ??
          (user.displayName ?? (isVishnu ? 'Vishnu Shaji' : 'Customer User')),
      phoneNumber:
          cachedPhone ??
          (user.phoneNumber ?? (isVishnu ? '+91 98460 77889' : '')),
      role: cachedRole ?? 'customer',
      garageId: cachedGarageId,
      avatarUrl: cachedAvatar,
      createdAt: DateTime.now(),
    );
    await _persistSession(fallbackProfile);

    state = state.copyWith(
      isLoading: false,
      isInitialized: true,
      userProfile: fallbackProfile,
      activeExperience: fallbackProfile.role == 'merchant'
          ? 'merchant'
          : 'customer',
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required String intendedRole,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseConfig.initialize();
      UserCredential? credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authErr) {
        if (authErr is FirebaseAuthException &&
            (authErr.code == 'network-request-failed' ||
                authErr.code == 'operation-not-allowed')) {
          credential = null;
        } else {
          rethrow;
        }
      }

      final uid = credential?.user?.uid ?? email.hashCode.abs().toString();
      UserProfileModel profile;

      final isVishnu =
          email.toLowerCase() == 'vishnushaji431@gmail.com' ||
          email.toLowerCase() == '318@gmail.com' ||
          email.toLowerCase().contains('vishnu');
      final defaultName = isVishnu
          ? 'Vishnu Shaji'
          : email.split('@').first.toUpperCase();
      final defaultPhone = isVishnu ? '+91 98460 77889' : '+91 98765 00000';
      const String? initialGarageId = null;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 2));
        if (doc.exists && doc.data() != null) {
          profile = UserProfileModel.fromFirestore(doc.data()!, uid);
        } else {
          profile = UserProfileModel(
            uid: uid,
            email: email,
            fullName: defaultName,
            phoneNumber: defaultPhone,
            role: intendedRole,
            garageId: initialGarageId,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(profile.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }
      } catch (_) {
        profile = UserProfileModel(
          uid: uid,
          email: email,
          fullName: defaultName,
          phoneNumber: defaultPhone,
          role: intendedRole,
          garageId: initialGarageId,
          createdAt: DateTime.now(),
        );
      }

      await _persistSession(profile);

      final authorizedExperience = profile.role == 'merchant'
          ? 'merchant'
          : 'customer';

      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeExperience: authorizedExperience,
      );
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(isLoading: false, errorMessage: appEx.message);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String intendedRole,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseConfig.initialize();
      UserCredential? credential;
      try {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (authErr) {
        if (authErr is FirebaseAuthException &&
            (authErr.code == 'network-request-failed' ||
                authErr.code == 'operation-not-allowed')) {
          credential = null;
        } else {
          rethrow;
        }
      }

      final uid = credential?.user?.uid ?? const Uuid().v4();
      final garageId = intendedRole == 'merchant' ? 'garage_$uid' : null;

      final profile = UserProfileModel(
        uid: uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: intendedRole,
        garageId: garageId,
        createdAt: DateTime.now(),
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(profile.toFirestore())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}

      await _persistSession(profile);

      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeExperience: intendedRole,
      );
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(isLoading: false, errorMessage: appEx.message);
      return false;
    }
  }

  Future<bool> signInWithGoogle({required String intendedRole}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseConfig.initialize();
      UserCredential credential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        credential = await FirebaseAuth.instance.signInWithPopup(
          googleProvider,
        );
      } else {
        const webClientId =
            '62265849009-mushlhju9uianaf4aqq4qtcj11kfiij5.apps.googleusercontent.com';
        final googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
          scopes: const ['email', 'profile'],
        );
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          state = state.copyWith(isLoading: false);
          return false;
        }
        final googleAuth = await googleUser.authentication;
        final authCred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await FirebaseAuth.instance.signInWithCredential(authCred);
      }

      final user = credential.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Google Sign-In failed to return user data.',
        );
        return false;
      }

      UserProfileModel profile;
      final photo = user.photoURL;
      final prefs = await SharedPreferences.getInstance();
      if (photo != null && photo.isNotEmpty) {
        await prefs.setString('user_avatar_${user.uid}', photo);
      }

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 2));
        if (doc.exists && doc.data() != null) {
          profile = UserProfileModel.fromFirestore(doc.data()!, user.uid);
          if (profile.avatarUrl == null && photo != null) {
            profile = profile.copyWith(avatarUrl: photo);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(profile.toFirestore(), SetOptions(merge: true))
                .timeout(const Duration(seconds: 2));
          }
        } else {
          final isVishnu =
              user.email?.toLowerCase() == 'vishnushaji431@gmail.com' ||
              user.email?.toLowerCase() == '318@gmail.com';
          final defaultName =
              user.displayName ?? (isVishnu ? 'Vishnu Shaji' : 'Google User');
          final defaultPhone =
              (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              ? user.phoneNumber!
              : (isVishnu ? '+91 98460 77889' : '');

          profile = UserProfileModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: defaultName,
            phoneNumber: defaultPhone,
            role: intendedRole,
            avatarUrl: photo,
            garageId: intendedRole == 'merchant' ? 'garage_${user.uid}' : null,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(profile.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }
      } catch (_) {
        final isVishnu =
            user.email?.toLowerCase() == 'vishnushaji431@gmail.com' ||
            user.email?.toLowerCase() == '318@gmail.com';
        final defaultName =
            user.displayName ?? (isVishnu ? 'Vishnu Shaji' : 'Google User');
        final defaultPhone =
            (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            ? user.phoneNumber!
            : (isVishnu ? '+91 98460 77889' : '');

        profile = UserProfileModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: defaultName,
          phoneNumber: defaultPhone,
          role: intendedRole,
          avatarUrl: photo,
          garageId: intendedRole == 'merchant' ? 'garage_${user.uid}' : null,
          createdAt: DateTime.now(),
        );
      }

      await _persistSession(profile);

      final authorizedExperience = profile.role == 'merchant'
          ? 'merchant'
          : 'customer';

      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeExperience: authorizedExperience,
      );
      return true;
    } catch (e, st) {
      debugPrint('SIGN_IN_WITH_GOOGLE_EXCEPTION: $e');
      debugPrint('SIGN_IN_WITH_GOOGLE_STACK: $st');
      final appEx = AppException.fromFirebase(e);
      if (appEx.code == 'auth-cancelled') {
        state = state.copyWith(isLoading: false, errorMessage: null);
        return false;
      }
      state = state.copyWith(isLoading: false, errorMessage: appEx.message);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } catch (_) {}
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(isLoading: false, errorMessage: appEx.message);
      return false;
    }
  }

  Future<void> switchExperience(String targetExperience) async {
    final current = state.userProfile;
    if (current == null) return;

    final updated = current.copyWith(
      role: targetExperience,
      garageId: targetExperience == 'merchant'
          ? (current.garageId != null && current.garageId!.isNotEmpty
                ? current.garageId
                : null)
          : null,
    );

    await _persistSession(updated);

    state = state.copyWith(
      activeExperience: targetExperience,
      userProfile: updated,
    );
  }

  Future<void> updateGarageId(String garageId) async {
    final current = state.userProfile;
    if (current == null) return;

    final updated = current.copyWith(garageId: garageId);
    await _persistSession(updated);
    state = state.copyWith(userProfile: updated);

    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .set(updated.toFirestore(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  void updateUserProfile(UserProfileModel profile) {
    _persistSession(profile);
    state = state.copyWith(userProfile: profile);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_session_uid');
      await prefs.remove('cached_session_email');
      await prefs.remove('cached_session_name');
      await prefs.remove('cached_session_role');
      await prefs.remove('cached_session_phone');
      await prefs.remove('cached_session_garage_id');
      await prefs.remove('cached_session_avatar');
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      ref.read(garageRepositoryProvider).clearCache();
    } catch (_) {}
    state = const AuthState(isInitialized: true);
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
