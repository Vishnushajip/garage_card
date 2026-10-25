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
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final isCustomer = _selectedRole == 'customer';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AppResponsiveLayout(
              maxWidth: 480,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                color: cardBg,
                elevation: isDark ? 0 : 2,
                shadowColor: Colors.black.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryRed
                                        .withValues(alpha: 0.32),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  'assets/branding/wefix_app_icon.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const AppLogo(size: 80, showBadge: true),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              AppBranding.appName,
                              style: AppFonts.displayLarge(
                                color: AppColors.primaryRed,
                              ).copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Vehicle service & smart garage management platform',
                              textAlign: TextAlign.center,
                              style: AppFonts.bodyMedium(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Select Account Type',
                        style: AppFonts.labelLarge(color: primaryTextColor),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _RoleCard(
                              title: 'Customer',
                              subtitle: 'Vehicle owner',
                              icon: Icons.directions_car_filled_rounded,
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoleCard(
                              title: 'Garage Owner',
                              subtitle: 'Merchant / Shop',
                              icon: Icons.storefront_rounded,
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
                      const SizedBox(height: 24),
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
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
                                  style: AppFonts.labelSmall(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      ElevatedButton(
                        onPressed: state.isLoading ? null : _onGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F2937),
                          elevation: 1,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          side: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size.fromHeight(52),
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
                                    style: AppFonts.labelLarge(
                                      color: const Color(0xFF1F2937),
                                    ).copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showEmailAuth = !_showEmailAuth;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _showEmailAuth
                                          ? 'Hide Email Sign-In'
                                          : 'Or sign in with email',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _showEmailAuth
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: secondaryTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                        ],
                      ),
                      if (_showEmailAuth) ...[
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_mode == AuthMode.signUp) ...[
                                AppTextField(
                                  controller: _nameCtrl,
                                  label: 'Full Name',
                                  hint: 'John Doe',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 20,
                                  ),
                                  required: true,
                                  enabled: !state.isLoading,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
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
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    size: 20,
                                  ),
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
                                const SizedBox(height: 14),
                              ],
                              AppTextField(
                                controller: _emailCtrl,
                                label: 'Email Address',
                                hint: 'user@example.com',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
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
                              const SizedBox(height: 14),
                              if (_mode != AuthMode.forgotPassword) ...[
                                AppTextField(
                                  controller: _passwordCtrl,
                                  label: 'Password',
                                  hint: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                  ),
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
                                const SizedBox(height: 6),
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
                                height: 48,
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: TextButton(
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
                      ],
                    ],
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
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
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.08)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isSelected
                      ? AppColors.primaryRed
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.primaryRed,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppFonts.labelLarge(
                color: isSelected ? AppColors.primaryRed : primaryTextColor,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppFonts.labelSmall(
                color: secondaryTextColor,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -0.7, 1.4, false, paintBlue);
    canvas.drawArc(rect, 0.7, 1.5, false, paintGreen);
    canvas.drawArc(rect, 2.2, 1.2, false, paintYellow);
    canvas.drawArc(rect, 3.4, 1.6, false, paintRed);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
