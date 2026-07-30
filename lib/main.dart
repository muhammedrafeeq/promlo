import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/marketplace_provider.dart';
import 'views/splash_screen.dart';
import 'views/trending_view.dart';
import 'views/categories_view.dart';
import 'views/collections_view.dart';
import 'views/prompt_details_view.dart';
import 'views/admin/admin_view.dart';
import 'views/privacy_policy_view.dart';
import 'services/analytics_service.dart';

import 'widgets/top_header.dart';
import 'widgets/mobile_bottom_nav.dart';

// ── Replace with your Supabase project values ──────────────────
const _supabaseUrl    = 'https://dmlorzjknvihhdravolw.supabase.co';
const _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtbG9yemprbnZpaGhkcmF2b2x3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyOTkyNzUsImV4cCI6MjEwMDg3NTI3NX0.0ruQgf93lqORlbMCgNFuHduY9DbrZnlDdllFO6cOXlk';
// ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      AnalyticsService.logError(error, stack, fatal: true);
      return true;
    };
  }

  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey);
  runApp(const PromloApp());
}

class PromloApp extends StatelessWidget {
  const PromloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketplaceProvider(),
      child: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Promlo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(child: MainShellScreen()),
            routes: {
              '/admin': (_) => const AdminView(),
              '/privacy': (_) => const PrivacyPolicyView(),
            },
          );
        },
      ),
    );
  }
}

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final isDetailOpen = provider.selectedPromptDetails != null;

    Widget bodyContent;
    Key pageKey;

    if (isDetailOpen) {
      pageKey = ValueKey('details_${provider.selectedPromptDetails!.id}');
      bodyContent = PromptDetailsView(
        prompt: provider.selectedPromptDetails!,
        onBack: () => provider.closePromptDetails(),
      );
    } else {
      pageKey = ValueKey('tab_${provider.activeTabIndex}');
      switch (provider.activeTabIndex) {
        case 0:
          bodyContent = const TrendingView();
          break;
        case 1:
          bodyContent = const CategoriesView();
          break;
        case 2:
          bodyContent = const CollectionsView();
          break;
        default:
          bodyContent = const TrendingView();
      }
    }

    final slideFromRight = isDetailOpen || provider.isNavigatingRight;

    return Scaffold(
      appBar: isDetailOpen ? null : TopHeader(),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: provider.isOnline
                  ? const SizedBox.shrink(key: ValueKey('online'))
                  : const _OfflineBanner(key: ValueKey('offline')),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isDetailOpen ? 0 : (isDesktop ? 32.0 : 16.0),
                  right: isDetailOpen ? 0 : (isDesktop ? 32.0 : 16.0),
                  top: isDetailOpen ? 0 : 16.0,
                  bottom: isDetailOpen ? 12.0 : 16.0,
                ),
                child: ClipRect(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    reverseDuration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isIncoming = child.key == pageKey;

                      // Incoming: slides in from the edge
                      // Outgoing: slides away with a slight parallax (moves less)
                      final incomingBegin = slideFromRight
                          ? const Offset(1.0, 0.0)
                          : const Offset(-1.0, 0.0);
                      final outgoingEnd = slideFromRight
                          ? const Offset(-0.3, 0.0)
                          : const Offset(0.3, 0.0);

                      final slideOffset = isIncoming
                          ? Tween<Offset>(begin: incomingBegin, end: Offset.zero)
                              .animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ))
                          : Tween<Offset>(begin: Offset.zero, end: outgoingEnd)
                              .animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInCubic,
                              ));

                      final fadeOpacity = isIncoming
                          ? CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.7, curve: Curves.easeIn))
                          : CurvedAnimation(parent: animation, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));

                      final scale = isIncoming
                          ? Tween<double>(begin: 0.96, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic))
                          : Tween<double>(begin: 1.0, end: 0.98).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeInCubic));

                      return SlideTransition(
                        position: slideOffset,
                        child: FadeTransition(
                          opacity: fadeOpacity,
                          child: ScaleTransition(
                            scale: scale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: SizedBox.expand(
                      key: pageKey,
                      child: bodyContent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (isDesktop || isDetailOpen) ? null : MobileBottomNav(),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: colors.tertiary.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: colors.tertiary),
          const SizedBox(width: 8),
          Text(
            'You\'re offline — showing cached data',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
