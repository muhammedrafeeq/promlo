import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static bool get _ready =>
      defaultTargetPlatform == TargetPlatform.android &&
      Firebase.apps.isNotEmpty;

  // ── Screen tracking ──────────────────────────────────────────────
  static Future<void> logScreen(String screenName) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  // ── Prompt events ────────────────────────────────────────────────
  static Future<void> logPromptView({
    required String promptId,
    required String promptTitle,
    required String category,
  }) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'prompt_view',
      parameters: {
        'prompt_id': promptId,
        'prompt_title': promptTitle.length > 40
            ? promptTitle.substring(0, 40)
            : promptTitle,
        'category': category,
      },
    );
  }

  static Future<void> logPromptCopy({
    required String promptId,
    required String category,
  }) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'prompt_copy',
      parameters: {'prompt_id': promptId, 'category': category},
    );
  }

  static Future<void> logPromptBookmark({
    required String promptId,
    required bool isBookmarked,
  }) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(
      name: isBookmarked ? 'prompt_bookmark_add' : 'prompt_bookmark_remove',
      parameters: {'prompt_id': promptId},
    );
  }

  static Future<void> logPromptLike({
    required String promptId,
    required bool isLiked,
  }) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(
      name: isLiked ? 'prompt_like' : 'prompt_unlike',
      parameters: {'prompt_id': promptId},
    );
  }

  // ── Search ───────────────────────────────────────────────────────
  static Future<void> logSearch(String query) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logSearch(searchTerm: query);
  }

  // ── Navigation ───────────────────────────────────────────────────
  static Future<void> logTabSwitch(int tabIndex) async {
    if (!_ready) return;
    const tabs = ['trending', 'categories', 'collections'];
    await FirebaseAnalytics.instance.logEvent(
      name: 'tab_switch',
      parameters: {
        'tab': tabIndex < tabs.length ? tabs[tabIndex] : '$tabIndex',
      },
    );
  }

  static Future<void> logCategoryOpen(String category) async {
    if (!_ready) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'category_open',
      parameters: {'category': category},
    );
  }

  // ── Errors & crashes ─────────────────────────────────────────────
  static Future<void> logError(
    dynamic error,
    StackTrace? stack, {
    String? context,
    bool fatal = false,
  }) async {
    if (!_ready) return;
    await FirebaseCrashlytics.instance
        .recordError(error, stack, reason: context, fatal: fatal);
  }

  static void logMessage(String message) {
    if (!_ready) return;
    FirebaseCrashlytics.instance.log(message);
  }

  static Future<void> setUserId(String? userId) async {
    if (!_ready) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  // ── Performance traces ───────────────────────────────────────────
  static HttpMetric? newHttpMetric(String url, HttpMethod method) {
    if (!_ready) return null;
    return FirebasePerformance.instance.newHttpMetric(url, method);
  }

  static Trace? newTrace(String name) {
    if (!_ready) return null;
    return FirebasePerformance.instance.newTrace(name);
  }
}
