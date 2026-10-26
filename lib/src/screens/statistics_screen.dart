import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../data/math_questions.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  final AppThemeMode? themeMode;

  const StatisticsScreen({
    super.key,
    this.themeMode,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _settingsService = SettingsService();
  final _dbService = DatabaseService();

  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalReads = 0;
  int _totalFavorites = 0;
  int _totalReadingMinutes = 0;
  List<Map<String, dynamic>> _mostViewedQuotes = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    await _settingsService.init();

    _currentStreak = _settingsService.getCurrentStreak();
    _longestStreak = _settingsService.getLongestStreak();
    _totalReads = _settingsService.getTotalReads();
    _totalReadingMinutes = (_settingsService.getTotalReadingTime() / 60).round();

    // Get total favorites count
    final db = await _dbService.database;
    final favResult = await db.rawQuery('SELECT COUNT(*) as count FROM favorite_quotes');
    _totalFavorites = favResult.first['count'] as int? ?? 0;

    // Get most viewed quotes
    final mostViewedIds = _settingsService.getMostViewedQuotes(5);
    _mostViewedQuotes = mostViewedIds.map((id) {
      final quote = getQuoteById(id);
      final views = _settingsService.getQuoteViews(id);
      return {
        'quote': quote,
        'views': views,
      };
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reading Journey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakSection(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildMostViewedSection(),
              const SizedBox(height: 24),
              _buildInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    final themeMode = widget.themeMode ?? AppThemeMode.ocean;
    final primaryColor = AppTheme.getPrimaryColorForMode(themeMode);
    final gradient = AppTheme.getPrimaryGradientForMode(themeMode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_currentStreak Day${_currentStreak != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_longestStreak > _currentStreak) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Your best: $_longestStreak day${_longestStreak != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          icon: '📖',
          value: _totalReads.toString(),
          label: 'Quotes Read',
          color: AppTheme.secondaryLagoon,
        ),
        _buildStatCard(
          icon: '❤️',
          value: _totalFavorites.toString(),
          label: 'Favorites',
          color: AppTheme.primarySunset,
        ),
        _buildStatCard(
          icon: '⏱️',
          value: _totalReadingMinutes.toString(),
          label: 'Minutes Reading',
          color: AppTheme.primaryForest,
        ),
        _buildStatCard(
          icon: '🏆',
          value: _longestStreak.toString(),
          label: 'Best Streak',
          color: AppTheme.accentSunrise,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostViewedSection() {
    if (_mostViewedQuotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Revisited Quotes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ..._mostViewedQuotes.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final quote = data['quote'];
          final views = data['views'];

          if (quote == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD2E6F5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '— ${quote.author}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOcean.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$views view${views != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryOcean,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInsightsSection() {
    final insights = _generateInsights();
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.subtleGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD2E6F5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    insight['icon'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight['text'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  List<Map<String, String>> _generateInsights() {
    final insights = <Map<String, String>>[];

    if (_currentStreak >= 7) {
      insights.add({
        'icon': '🎉',
        'text': 'Amazing! You\'ve maintained a week-long reading streak!',
      });
    }

    if (_totalFavorites >= 50) {
      insights.add({
        'icon': '📚',
        'text': 'You\'ve built an impressive collection of $_totalFavorites favorite quotes!',
      });
    }

    if (_totalReads >= 100) {
      insights.add({
        'icon': '🌟',
        'text': 'Wow! You\'ve read over $_totalReads quotes. You\'re a wisdom seeker!',
      });
    }

    if (_currentStreak == 0 && _longestStreak > 0) {
      insights.add({
        'icon': '💪',
        'text': 'Ready to start a new streak? Your best was $_longestStreak days!',
      });
    }

    if (insights.isEmpty && _totalReads > 0) {
      insights.add({
        'icon': '🚀',
        'text': 'Keep going! Read daily to build your streak and discover more wisdom.',
      });
    }

    return insights;
  }
}
