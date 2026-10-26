import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../Model/customer_profile_state.dart';

class CustomerProfileViewModel extends Notifier<CustomerProfileState> {
  @override
  CustomerProfileState build() {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    return CustomerProfileState(
      userProfile: user,
      nameInput: user?.fullName ?? '',
      phoneInput: user?.phoneNumber ?? '',
      whatsappInput: user?.whatsappNumber ?? '',
    );
  }

  void setName(String name) {
    state = state.copyWith(
      nameInput: name,
      errorMessage: null,
      successMessage: null,
    );
  }

  void setPhone(String phone) {
    state = state.copyWith(
      phoneInput: phone,
      errorMessage: null,
      successMessage: null,
    );
  }

  void setWhatsApp(String whatsapp) {
    state = state.copyWith(
      whatsappInput: whatsapp,
      errorMessage: null,
      successMessage: null,
    );
  }

  void copyPhoneToWhatsApp() {
    setWhatsApp(state.phoneInput);
  }

  Future<bool> saveProfile() async {
    final trimmedName = state.nameInput.trim();
    final trimmedPhone = state.phoneInput.trim();
    final trimmedWhatsApp = state.whatsappInput.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your full name');
      return false;
    }
    if (trimmedPhone.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your phone number');
      return false;
    }
    if (trimmedWhatsApp.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter your WhatsApp number for repair updates',
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final current = state.userProfile;
      if (current == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'User session not found',
        );
        return false;
      }

      final updated = current.copyWith(
        fullName: trimmedName,
        phoneNumber: trimmedPhone,
        whatsappNumber: trimmedWhatsApp,
        updatedAt: DateTime.now(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .set(updated.toFirestore(), SetOptions(merge: true));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone_${current.uid}', trimmedPhone);
      await prefs.setString('user_whatsapp_${current.uid}', trimmedWhatsApp);

      ref.read(authViewModelProvider.notifier).updateUserProfile(updated);

      state = state.copyWith(
        isSaving: false,
        userProfile: updated,
        successMessage: 'Profile completed successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String whatsappNumber = '',
  }) async {
    setName(fullName);
    setPhone(phoneNumber);
    if (whatsappNumber.isNotEmpty) {
      setWhatsApp(whatsappNumber);
    } else {
      copyPhoneToWhatsApp();
    }
    await saveProfile();
  }

  Future<bool> uploadAvatar(XFile file) async {
    final current = state.userProfile;
    if (current == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final refPath =
          'users/${current.uid}/avatars/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';

      String downloadUrl = '';
      if (FirebaseConfig.isInitialized) {
        final storageRef = FirebaseStorage.instance.ref(refPath);
        final metadata = SettableMetadata(
          contentType: file.mimeType ?? 'image/jpeg',
        );
        final task = await storageRef.putData(bytes, metadata);
        downloadUrl = await task.ref.getDownloadURL();
      }

      if (downloadUrl.isEmpty) {
        downloadUrl = file.path;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_${current.uid}', downloadUrl);

      final updated = current.copyWith(
        avatarUrl: downloadUrl,
        updatedAt: DateTime.now(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .set(updated.toFirestore(), SetOptions(merge: true));
      }

      ref.read(authViewModelProvider.notifier).updateUserProfile(updated);

      state = state.copyWith(
        isSaving: false,
        userProfile: updated,
        successMessage: 'Profile photo updated successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to upload photo: $e',
      );
      return false;
    }
  }
}

final customerProfileViewModelProvider =
    NotifierProvider<CustomerProfileViewModel, CustomerProfileState>(
      CustomerProfileViewModel.new,
    );
