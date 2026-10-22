import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/app_backend_service.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/mindspark_loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isGoogleLoading = false;
  bool _isGuestLoading = false;
  bool _termsAccepted = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_termsAccepted) return;
    setState(() => _isGoogleLoading = true);
    final result = await AppBackendService.instance.signInWithGoogle();
    if (!mounted) return;

    if (result.isCancelled) {
      // User ne account picker band kar diya — koi error nahi, sirf state reset.
      setState(() => _isGoogleLoading = false);
      return;
    }

    if (result.isDeletionPending) {
      setState(() => _isGoogleLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1B2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.amberAccent, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account Deletion Pending',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Aapne is Google account ko delete karne ki request ki hui hai.\n\n30 days ke procedure ke mutabiq admin is account ko permanently delete kar dega. Tab tak aap is Gmail account se login nahi kar sakte.\n\nAap kisi doosri Gmail se login kar sakte hain ya as a Guest khel sakte hain.\n\nJab account permanently delete ho jayega, uske baad aap is Gmail se naya account bana sakte hain.',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!result.isSuccess) {
      setState(() => _isGoogleLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Sign in failed. Please try again.'),
          backgroundColor: const Color(0xFF3D2B5E),
        ),
      );
    } else {
      // Login successful: force load game state from Firestore
      await ref.read(gameStateProvider).load(force: true);
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy to continue.'),
          backgroundColor: Color(0xFF3D2B5E),
        ),
      );
      return;
    }
    setState(() => _isGuestLoading = true);
    final success = await AppBackendService.instance.signInAnonymously();
    if (!mounted) return;
    if (!success) {
      setState(() => _isGuestLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest sign in failed. Please check internet connection and try again.'),
          backgroundColor: Color(0xFF3D2B5E),
        ),
      );
    } else {
      // Guest login successful: load game state
      await ref.read(gameStateProvider).load(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Image.asset(
                      AppAssets.splashLogo,
                      width: 130,
                      height: 130,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.psychology,
                        size: 100,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // App name
                    Text(
                      AppStrings.appName,
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 36,
                                letterSpacing: 1.5,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.tagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    // Heading
                    Text(
                      'Welcome to Mind Spark',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 26,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to save your progress\nor play as guest instantly',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Terms & Conditions Checkbox
                    _TermsCheckbox(
                      accepted: _termsAccepted,
                      onChanged: (v) => setState(() => _termsAccepted = v),
                      onTermsTap: () => context.push(AppRoutes.terms),
                      onPrivacyTap: () => context.push(AppRoutes.privacyPolicy),
                    ),

                    const SizedBox(height: 16),

                    // Google Sign In Button
                    _GoogleSignInButton(
                      isLoading: _isGoogleLoading,
                      enabled: _termsAccepted && !_isGuestLoading,
                      onPressed: _handleGoogleSignIn,
                    ),

                    const SizedBox(height: 14),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.20),
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.20),
                            height: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Play as Guest Button
                    _GuestSignInButton(
                      isLoading: _isGuestLoading,
                      enabled: _termsAccepted && !_isGoogleLoading,
                      onPressed: _handleGuestSignIn,
                    ),

                    const Spacer(flex: 2),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Terms Checkbox Widget ──────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.accepted,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: accepted,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryLight,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryLight,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Google Sign In Button ──────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1.0 : 0.45,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (isLoading || !enabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F1F1F),
            disabledBackgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: MindSparkLoadingIndicator(size: 30),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GoogleLogo(),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Play as Guest Button ──────────────────────────────────────────────────

class _GuestSignInButton extends StatelessWidget {
  const _GuestSignInButton({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1.0 : 0.45,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: (isLoading || !enabled) ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: MindSparkLoadingIndicator(size: 30),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 22,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Play as Guest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.35
      ..strokeCap = StrokeCap.butt;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.35
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.35
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.35
      ..strokeCap = StrokeCap.butt;

    final arcR = r * 0.65;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: arcR);

    canvas.drawArc(rect, -1.0, 1.8, false, bluePaint);
    canvas.drawArc(rect, 0.8, 1.6, false, yellowPaint);
    canvas.drawArc(rect, 2.4, 1.6, false, greenPaint);
    canvas.drawArc(rect, 4.0, 1.0, false, redPaint);

    final barPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = r * 0.35
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(Offset(cx, cy), Offset(cx + arcR, cy), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
