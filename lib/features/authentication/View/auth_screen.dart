import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import '../ViewModel/auth_view_model.dart';
import '../Widgets/auth_role_selector.dart';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(authViewModelProvider.notifier);

    if (_mode == AuthMode.signIn) {
      vm.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        intendedRole: _selectedRole,
      );
    } else if (_mode == AuthMode.signUp) {
      vm.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        intendedRole: _selectedRole,
      );
    } else {
      vm.resetPassword(_emailCtrl.text.trim()).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset instructions sent to your email.'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _mode = AuthMode.signIn;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AppResponsiveLayout(
              maxWidth: 480,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: AppLogo(size: 64)),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            AppBranding.appName,
                            style: AppFonts.displayMedium(color: primaryTextColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            AppBranding.appTagline,
                            style: AppFonts.bodyMedium(color: secondaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (state.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        if (_mode != AuthMode.forgotPassword) ...[
                          AuthRoleSelector(
                            selectedRole: _selectedRole,
                            onRoleChanged: (role) {
                              setState(() {
                                _selectedRole = role;
                              });
                            },
                            enabled: !state.isLoading,
                          ),
                          const SizedBox(height: 18),
                        ],
                        if (_mode == AuthMode.signUp) ...[
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'e.g. Rahul Sharma',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            required: true,
                            enabled: !state.isLoading,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _phoneCtrl,
                            label: 'Phone Number',
                            hint: 'e.g. +91 98765 43210',
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            keyboardType: TextInputType.phone,
                            required: true,
                            enabled: !state.isLoading,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                        ],
                        AppTextField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          hint: 'e.g. name@example.com',
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          keyboardType: TextInputType.emailAddress,
                          required: true,
                          enabled: !state.isLoading,
                          validator: (v) {
                            if (v == null || !v.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        if (_mode != AuthMode.forgotPassword) ...[
                          AppTextField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            isPassword: true,
                            required: true,
                            enabled: !state.isLoading,
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _mode = AuthMode.forgotPassword;
                                      });
                                    },
                              child: Text(
                                'Forgot Password?',
                                style: AppFonts.labelSmall(
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        AppButton(
                          label: _mode == AuthMode.signIn
                              ? 'Sign In to Account'
                              : _mode == AuthMode.signUp
                                  ? 'Create Account'
                                  : 'Send Reset Link',
                          isLoading: state.isLoading,
                          isFullWidth: true,
                          onPressed: _submit,
                          height: 50,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _mode == AuthMode.signIn
                                  ? "Don't have an account?"
                                  : 'Already have an account?',
                              style:
                                  AppFonts.bodyMedium(color: secondaryTextColor),
                            ),
                            TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _mode = _mode == AuthMode.signIn
                                            ? AuthMode.signUp
                                            : AuthMode.signIn;
                                      });
                                    },
                              child: Text(
                                _mode == AuthMode.signIn
                                    ? 'Register Now'
                                    : 'Sign In',
                                style: AppFonts.labelLarge(
                                  color: AppColors.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
