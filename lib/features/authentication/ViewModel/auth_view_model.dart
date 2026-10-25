import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/errors/app_exception.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';

import '../Model/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    try {
      if (FirebaseConfig.isInitialized) {
        final currentFirebaseUser = FirebaseAuth.instance.currentUser;
        if (currentFirebaseUser != null) {
          _restoreExistingSession(currentFirebaseUser);
          return const AuthState(isLoading: true, isInitialized: false);
        }
      } else {
        FirebaseConfig.initialize().then((_) {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              _restoreExistingSession(user);
            }
          } catch (_) {}
        });
      }
    } catch (_) {}
    return const AuthState(isLoading: false, isInitialized: true);
  }

  Future<void> _restoreExistingSession(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final profile = UserProfileModel.fromFirestore(doc.data()!, user.uid);
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

    final fallbackProfile = UserProfileModel(
      uid: user.uid,
      email: user.email ?? 'user@garagecard.app',
      fullName: user.displayName ?? 'Customer User',
      phoneNumber: user.phoneNumber ?? '',
      role: 'customer',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      isLoading: false,
      isInitialized: true,
      userProfile: fallbackProfile,
      activeExperience: 'customer',
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

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (doc.exists && doc.data() != null) {
          profile = UserProfileModel.fromFirestore(doc.data()!, uid);
        } else {
          profile = UserProfileModel(
            uid: uid,
            email: email,
            fullName: email.split('@').first.toUpperCase(),
            phoneNumber: '+91 98765 00000',
            role: intendedRole,
            garageId: intendedRole == 'merchant' ? 'garage_demo_1' : null,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(profile.toFirestore(), SetOptions(merge: true));
        }
      } catch (_) {
        profile = UserProfileModel(
          uid: uid,
          email: email,
          fullName: email.split('@').first.toUpperCase(),
          phoneNumber: '+91 98765 00000',
          role: intendedRole,
          garageId: intendedRole == 'merchant' ? 'garage_demo_1' : null,
          createdAt: DateTime.now(),
        );
      }

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
            .set(profile.toFirestore());
      } catch (_) {}

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
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          profile = UserProfileModel.fromFirestore(doc.data()!, user.uid);
        } else {
          profile = UserProfileModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? 'Google User',
            phoneNumber: user.phoneNumber ?? '',
            role: intendedRole,
            garageId: intendedRole == 'merchant' ? 'garage_demo_1' : null,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(profile.toFirestore(), SetOptions(merge: true));
        }
      } catch (_) {
        profile = UserProfileModel(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'Google User',
          phoneNumber: user.phoneNumber ?? '',
          role: intendedRole,
          garageId: intendedRole == 'merchant' ? 'garage_demo_1' : null,
          createdAt: DateTime.now(),
        );
      }

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

  void switchExperience(String targetExperience) {
    if (state.userProfile == null) return;
    if (targetExperience == 'merchant' &&
        state.userProfile?.role != 'merchant') {
      state = state.copyWith(
        errorMessage:
            'Unauthorized: Your account does not have merchant privileges.',
      );
      return;
    }
    state = state.copyWith(activeExperience: targetExperience);
  }

  void updateUserProfile(UserProfileModel profile) {
    state = state.copyWith(userProfile: profile);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    state = const AuthState(isInitialized: true);
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
