import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _exitCtrl;

  // Logo: scale + fade
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Text: slide up + fade
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // Ambient glow pulse
  late final Animation<double> _glowOpacity;

  // Exit: whole screen fade out
  late final Animation<double> _exitOpacity;

  bool _showChild = false;
  bool _showChildBehind = false; // only true when exit fade begins

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/promlo_logo_v6.png'), context);
  }

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.7)));

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Logo appears immediately
    await _logoCtrl.forward();

    // Text slides in right after
    await Future.delayed(const Duration(milliseconds: 80));
    await _textCtrl.forward();

    // Hold on screen
    await Future.delayed(const Duration(milliseconds: 1000));

    // Bring child in before fade-out so it's rendered and ready
    if (mounted) setState(() => _showChildBehind = true);
    await Future.delayed(const Duration(milliseconds: 150));

    // Fade out entire splash
    _glowCtrl.stop();
    await _exitCtrl.forward();

    if (mounted) setState(() => _showChild = true);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _glowCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showChild) return widget.child;

    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoCtrl,
        _textCtrl,
        _glowCtrl,
        _exitCtrl,
      ]),
      builder: (context, _) {
        return Stack(
          children: [
            // Main screen only added to tree just before fade-out
            if (_showChildBehind) widget.child,
            FadeTransition(
              opacity: _exitOpacity,
              child: Scaffold(
            backgroundColor: colors.background,
            body: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Ambient glow blobs
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.18,
                  child: Opacity(
                    opacity: _glowOpacity.value * 0.5,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.35),
                            colors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.22,
                  child: Opacity(
                    opacity: _glowOpacity.value * 0.3,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colors.secondary.withValues(alpha: 0.3),
                            colors.secondary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo inside glassmorphic card
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                                colors.secondary.withValues(alpha: isDark ? 0.10 : 0.07),
                              ],
                            ),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              'assets/promlo_logo_v6.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name + description
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            Text(
                              'Promlo',
                              style: GoogleFonts.sora(
                                fontSize: AppSizes.of(context).isSmall ? 28 : 36,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI Prompt Marketplace',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colors.onSurfaceVariant,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          ],
        );
      },
    );
  }
}
