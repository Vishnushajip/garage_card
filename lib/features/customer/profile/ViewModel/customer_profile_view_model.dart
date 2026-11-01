import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/services/image_upload_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../Model/customer_profile_state.dart';

class CustomerProfileViewModel extends Notifier<CustomerProfileState> {
  String _stripCountryCode(String phone) {
    var cleaned = phone.trim();
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3).trim();
    } else if (cleaned.startsWith('+')) {
      final match = RegExp(r'^\+\d{1,3}\s*').firstMatch(cleaned);
      if (match != null) {
        cleaned = cleaned.substring(match.end).trim();
      }
    }
    return cleaned;
  }

  @override
  CustomerProfileState build() {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final rawName = user?.fullName ?? '';
    final cleanName = (rawName == 'User' || rawName.contains('Vishnu'))
        ? ''
        : rawName;
    final rawPhone = user?.phoneNumber ?? '';
    final cleanPhone =
        (rawPhone.contains('98460') || rawPhone.contains('9876500000'))
        ? ''
        : _stripCountryCode(rawPhone);
    final rawWhatsapp = user?.whatsappNumber ?? '';
    final cleanWhatsapp =
        (rawWhatsapp.contains('98460') || rawWhatsapp.contains('9876500000'))
        ? ''
        : _stripCountryCode(rawWhatsapp);
    return CustomerProfileState(
      userProfile: user,
      nameInput: cleanName,
      phoneInput: cleanPhone,
      whatsappInput: cleanWhatsapp,
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

  void setEditingDetails(bool isEditing) {
    state = state.copyWith(isEditingDetails: isEditing);
  }

  void startEditingDetails() {
    final user = state.userProfile;
    final initialName = (user?.fullName != null && user!.fullName != 'User')
        ? user.fullName
        : state.nameInput;
    state = state.copyWith(
      isEditingDetails: true,
      nameInput: initialName,
      phoneInput: user?.phoneNumber.isNotEmpty == true
          ? user!.phoneNumber
          : state.phoneInput,
      whatsappInput: user?.whatsappNumber.isNotEmpty == true
          ? user!.whatsappNumber
          : state.whatsappInput,
      errorMessage: null,
      successMessage: null,
    );
  }

  void cancelEditingDetails() {
    state = state.copyWith(
      isEditingDetails: false,
      errorMessage: null,
      successMessage: null,
    );
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
        isEditingDetails: false,
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
      final imageService = ref.read(imageUploadServiceProvider);
      final uploaded = await imageService.uploadImage(
        file: file,
        folder: 'users/${current.uid}/avatars',
        entityId: 'avatar',
        profile: ImageProfile.thumbnail,
        previousImageUrl: current.avatarUrl,
      );

      final downloadUrl = uploaded.downloadUrl;
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
