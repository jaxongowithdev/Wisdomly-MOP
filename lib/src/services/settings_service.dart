import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Theme Settings
  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs?.setString('theme_mode', mode.name);
  }

  AppThemeMode getThemeMode() {
    final themeName = _prefs?.getString('theme_mode') ?? 'ocean';
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => AppThemeMode.ocean,
    );
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool('is_dark_mode', isDark);
  }

  bool getDarkMode() {
    return _prefs?.getBool('is_dark_mode') ?? false;
  }

  // Reading Streak
  Future<void> updateReadingStreak() async {
    final today = DateTime.now();
    final lastReadDate = getLastReadDate();
    final currentStreak = getCurrentStreak();

    if (lastReadDate == null) {
      // First time reading
      await _prefs?.setInt('current_streak', 1);
      await _prefs?.setInt('longest_streak', 1);
    } else {
      final daysDifference = _daysBetween(lastReadDate, today);

      if (daysDifference == 0) {
        // Already read today, do nothing
        return;
      } else if (daysDifference == 1) {
        // Continue streak
        final newStreak = currentStreak + 1;
        await _prefs?.setInt('current_streak', newStreak);

        final longestStreak = getLongestStreak();
        if (newStreak > longestStreak) {
          await _prefs?.setInt('longest_streak', newStreak);
        }
      } else {
        // Streak broken
        await _prefs?.setInt('current_streak', 1);
      }
    }

    await _prefs?.setString('last_read_date', today.toIso8601String());

    // Update total reads
    final totalReads = getTotalReads();
    await _prefs?.setInt('total_reads', totalReads + 1);
  }

  int getCurrentStreak() {
    return _prefs?.getInt('current_streak') ?? 0;
  }

  int getLongestStreak() {
    return _prefs?.getInt('longest_streak') ?? 0;
  }

  int getTotalReads() {
    return _prefs?.getInt('total_reads') ?? 0;
  }

  DateTime? getLastReadDate() {
    final dateStr = _prefs?.getString('last_read_date');
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inDays;
  }

  // Quote Statistics
  Future<void> incrementQuoteView(int quoteId) async {
    final views = getQuoteViews(quoteId);
    await _prefs?.setInt('quote_views_$quoteId', views + 1);
  }

  int getQuoteViews(int quoteId) {
    return _prefs?.getInt('quote_views_$quoteId') ?? 0;
  }

  Future<void> saveLastViewedQuote(int quoteId) async {
    await _prefs?.setInt('last_viewed_quote', quoteId);
  }

  int? getLastViewedQuote() {
    return _prefs?.getInt('last_viewed_quote');
  }

  // Get most viewed quotes
  List<int> getMostViewedQuotes(int limit) {
    final keys = _prefs?.getKeys() ?? {};
    final quoteViews = <int, int>{};

    for (final key in keys) {
      if (key.startsWith('quote_views_')) {
        final quoteId = int.tryParse(key.replaceFirst('quote_views_', ''));
        if (quoteId != null) {
          quoteViews[quoteId] = _prefs?.getInt(key) ?? 0;
        }
      }
    }

    final sorted = quoteViews.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  // Reading time tracking
  Future<void> addReadingTime(int seconds) async {
    final totalTime = getTotalReadingTime();
    await _prefs?.setInt('total_reading_time', totalTime + seconds);
  }

  int getTotalReadingTime() {
    return _prefs?.getInt('total_reading_time') ?? 0;
  }

  // Daily quote
  Future<void> setDailyQuoteId(int quoteId) async {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    await _prefs?.setString('daily_quote_date', todayKey);
    await _prefs?.setInt('daily_quote_id', quoteId);
  }

  int? getDailyQuoteId() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final savedDate = _prefs?.getString('daily_quote_date');

    if (savedDate == todayKey) {
      return _prefs?.getInt('daily_quote_id');
    }
    return null;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
