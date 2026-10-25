import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

import '../ViewModel/auth_view_model.dart';

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
  bool _showEmailAuth = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onGoogleSignIn() {
    ref
        .read(authViewModelProvider.notifier)
        .signInWithGoogle(intendedRole: _selectedRole);
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
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final isCustomer = _selectedRole == 'customer';
    final deepRed = Color.lerp(AppColors.primaryRed, Colors.black, 0.4)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AppResponsiveLayout(
              maxWidth: 480,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 56),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryRed, deepRed],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -20,
                          child: PhosphorIcon(
                            PhosphorIcons.gear(PhosphorIconsStyle.duotone),
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: -30,
                          child: PhosphorIcon(
                            PhosphorIcons.wrench(PhosphorIconsStyle.duotone),
                            size: 90,
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/branding/wefix_app_icon.png',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const AppLogo(
                                                size: 64,
                                                showBadge: true,
                                              ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome to',
                                        style: AppFonts.labelSmall(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        AppBranding.appName,
                                        style: AppFonts.displayLarge(
                                          color: Colors.white,
                                        ).copyWith(fontSize: 28),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Vehicle service & smart garage management platform',
                              style: AppFonts.bodyMedium(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _FeatureChip(
                                  icon: PhosphorIcons.wrench(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  label: 'Book Services',
                                ),
                                _FeatureChip(
                                  icon: PhosphorIcons.shieldCheck(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  label: 'Trusted Garages',
                                ),
                                _FeatureChip(
                                  icon: PhosphorIcons.lightning(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  label: 'Fast Updates',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: sheetBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'I am a',
                            style: AppFonts.labelLarge(color: primaryTextColor),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.primaryRed.withValues(
                                      alpha: 0.06,
                                    ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _RoleTab(
                                    title: 'Customer',
                                    subtitle: 'Vehicle owner',
                                    icon: PhosphorIcons.carProfile(
                                      isCustomer
                                          ? PhosphorIconsStyle.fill
                                          : PhosphorIconsStyle.duotone,
                                    ),
                                    isSelected: isCustomer,
                                    onTap: state.isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedRole = 'customer';
                                            });
                                          },
                                  ),
                                ),
                                Expanded(
                                  child: _RoleTab(
                                    title: 'Garage Owner',
                                    subtitle: 'Merchant / Shop',
                                    icon: PhosphorIcons.storefront(
                                      !isCustomer
                                          ? PhosphorIconsStyle.fill
                                          : PhosphorIconsStyle.duotone,
                                    ),
                                    isSelected: !isCustomer,
                                    onTap: state.isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedRole = 'merchant';
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            child: state.errorMessage != null
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border(
                                          left: const BorderSide(
                                            color: AppColors.error,
                                            width: 4,
                                          ),
                                          top: BorderSide(
                                            color: AppColors.error.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          right: BorderSide(
                                            color: AppColors.error.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          bottom: BorderSide(
                                            color: AppColors.error.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          PhosphorIcon(
                                            PhosphorIcons.warningCircle(
                                              PhosphorIconsStyle.fill,
                                            ),
                                            color: AppColors.error,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              state.errorMessage!,
                                              style: AppFonts.labelSmall(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: state.isLoading ? null : _onGoogleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.cardDark
                                  : Colors.white,
                              foregroundColor: primaryTextColor,
                              elevation: 0,
                              side: BorderSide(color: borderColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size.fromHeight(56),
                            ),
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryRed,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const _GoogleGLogo(size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
                                        style:
                                            AppFonts.labelLarge(
                                              color: primaryTextColor,
                                            ).copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _showEmailAuth = !_showEmailAuth;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _showEmailAuth
                                      ? AppColors.primaryRed.withValues(
                                          alpha: 0.5,
                                        )
                                      : borderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  PhosphorIcon(
                                    PhosphorIcons.envelopeSimple(
                                      PhosphorIconsStyle.duotone,
                                    ),
                                    size: 22,
                                    color: AppColors.primaryRed,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _showEmailAuth
                                          ? 'Hide Email Sign-In'
                                          : 'Or sign in with email',
                                      style: AppFonts.labelLarge(
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _showEmailAuth ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: PhosphorIcon(
                                      PhosphorIcons.caretDown(
                                        PhosphorIconsStyle.bold,
                                      ),
                                      size: 16,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: !_showEmailAuth
                                ? const SizedBox(width: double.infinity)
                                : Padding(
                                    padding: const EdgeInsets.only(top: 18),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (_mode !=
                                              AuthMode.forgotPassword) ...[
                                            _ModeSwitch(
                                              isSignIn:
                                                  _mode == AuthMode.signIn,
                                              enabled: !state.isLoading,
                                              onChanged: (signIn) {
                                                setState(() {
                                                  _mode = signIn
                                                      ? AuthMode.signIn
                                                      : AuthMode.signUp;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 18),
                                          ] else ...[
                                            Row(
                                              children: [
                                                PhosphorIcon(
                                                  PhosphorIcons.lockKeyOpen(
                                                    PhosphorIconsStyle.duotone,
                                                  ),
                                                  size: 24,
                                                  color: AppColors.primaryRed,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Reset your password',
                                                    style: AppFonts.labelLarge(
                                                      color: primaryTextColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          if (_mode == AuthMode.signUp) ...[
                                            AppTextField(
                                              controller: _nameCtrl,
                                              label: 'Full Name',
                                              hint: 'John Doe',
                                              prefixIcon: PhosphorIcon(
                                                PhosphorIcons.user(
                                                  PhosphorIconsStyle.duotone,
                                                ),
                                                size: 20,
                                              ),
                                              required: true,
                                              enabled: !state.isLoading,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Please enter your full name';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                            AppTextField(
                                              controller: _phoneCtrl,
                                              label: 'Phone Number',
                                              hint: '+91 98765 43210',
                                              prefixIcon: PhosphorIcon(
                                                PhosphorIcons.phone(
                                                  PhosphorIconsStyle.duotone,
                                                ),
                                                size: 20,
                                              ),
                                              keyboardType: TextInputType.phone,
                                              required: true,
                                              enabled: !state.isLoading,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.trim().isEmpty) {
                                                  return 'Please enter your phone number';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 14),
                                          ],
                                          AppTextField(
                                            controller: _emailCtrl,
                                            label: 'Email Address',
                                            hint: 'user@example.com',
                                            prefixIcon: PhosphorIcon(
                                              PhosphorIcons.envelopeSimple(
                                                PhosphorIconsStyle.duotone,
                                              ),
                                              size: 20,
                                            ),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            required: true,
                                            enabled: !state.isLoading,
                                            validator: (v) {
                                              if (v == null ||
                                                  !v.contains('@')) {
                                                return 'Please enter a valid email address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 14),
                                          if (_mode !=
                                              AuthMode.forgotPassword) ...[
                                            AppTextField(
                                              controller: _passwordCtrl,
                                              label: 'Password',
                                              hint: '••••••••',
                                              prefixIcon: PhosphorIcon(
                                                PhosphorIcons.lockSimple(
                                                  PhosphorIconsStyle.duotone,
                                                ),
                                                size: 20,
                                              ),
                                              isPassword: true,
                                              required: true,
                                              enabled: !state.isLoading,
                                              validator: (v) {
                                                if (v == null ||
                                                    v.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 6),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: state.isLoading
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _mode = AuthMode
                                                              .forgotPassword;
                                                        });
                                                      },
                                                child: Text(
                                                  'Forgot Password?',
                                                  style: AppFonts.labelSmall(
                                                    color: AppColors.primaryRed,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          AppButton(
                                            label: _mode == AuthMode.signIn
                                                ? 'Sign In to Account'
                                                : _mode == AuthMode.signUp
                                                ? 'Create Account'
                                                : 'Send Reset Link',
                                            isLoading: state.isLoading,
                                            isFullWidth: true,
                                            onPressed: _submit,
                                            height: 52,
                                          ),
                                          const SizedBox(height: 10),
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: state.isLoading
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _mode =
                                                            _mode ==
                                                                AuthMode.signIn
                                                            ? AuthMode.signUp
                                                            : AuthMode.signIn;
                                                      });
                                                    },
                                              icon: PhosphorIcon(
                                                _mode == AuthMode.signIn
                                                    ? PhosphorIcons.userPlus(
                                                        PhosphorIconsStyle
                                                            .bold,
                                                      )
                                                    : PhosphorIcons
                                                          .arrowLeft(
                                                            PhosphorIconsStyle
                                                                .bold,
                                                          ),
                                                size: 16,
                                                color: AppColors.primaryRed,
                                              ),
                                              label: Text(
                                                _mode == AuthMode.signIn
                                                    ? "Don't have an account? Register Now"
                                                    : 'Already have an account? Sign In',
                                                style: AppFonts.labelSmall(
                                                  color: AppColors.primaryRed,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: AppFonts.labelSmall(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.isSignIn,
    required this.onChanged,
    required this.enabled,
  });

  final bool isSignIn;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    Widget item(String label, IconData icon, bool selected, bool value) {
      return Expanded(
        child: GestureDetector(
          onTap: enabled ? () => onChanged(value) : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryRed : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppFonts.labelSmall(
                    color: selected ? Colors.white : secondaryTextColor,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark
            : AppColors.primaryRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          item(
            'Sign In',
            PhosphorIcons.signIn(PhosphorIconsStyle.bold),
            isSignIn,
            true,
          ),
          item(
            'Register',
            PhosphorIcons.userPlus(PhosphorIconsStyle.bold),
            !isSignIn,
            false,
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.surfaceDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.transparent,
            width: 1.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryRed.withValues(alpha: 0.12)
                    : secondaryTextColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.primaryRed : secondaryTextColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.labelSmall(
                      color: isSelected
                          ? AppColors.primaryRed
                          : primaryTextColor,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.labelSmall(
                      color: secondaryTextColor,
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGLogo extends StatelessWidget {
  const _GoogleGLogo({this.size = 22});

  final double size;

  static const String _svg = r'''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(_svg),
    );
  }
}