import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/math_questions.dart';
import '../models/quote.dart';
import '../models/fav_quote.dart';
import '../models/reader.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/quote_share_card.dart';
import 'quote_screen.dart';
import 'scoreboard_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return const QuoteGardenApp();
  }
}

class QuoteGardenApp extends StatefulWidget {
  const QuoteGardenApp({super.key});

  @override
  State<QuoteGardenApp> createState() => _QuoteGardenAppState();
}

class _QuoteGardenAppState extends State<QuoteGardenApp> {
  final DatabaseService _dbService = DatabaseService();
  final SettingsService _settingsService = SettingsService();
  bool _isLoading = true;
  QuoteReader? _reader;
  AppThemeMode _themeMode = AppThemeMode.ocean;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadReader();
    _loadThemeSettings();
  }

  Future<void> _loadReader() async {
    try {
      final reader = await _dbService.getFirstReader();
      if (!mounted) return;
      setState(() {
        _reader = reader;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadThemeSettings() async {
    await _settingsService.init();
    setState(() {
      _themeMode = _settingsService.getThemeMode();
      _isDarkMode = _settingsService.getDarkMode();
    });
  }

  void _handleThemeChange(AppThemeMode mode, bool isDark) {
    setState(() {
      _themeMode = mode;
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getThemeForMode(_themeMode, _isDarkMode);

    return MaterialApp(
      title: 'Wisdomly MOP',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme),
      ),
      home: _isLoading
          ? const LoadingScreen()
          : _reader == null
              ? NameSetupScreen(onReaderCreated: (reader) {
                  setState(() {
                    _reader = reader;
                  });
                })
              : HomeScreen(
                  reader: _reader!,
                  themeMode: _themeMode,
                  onThemeChanged: _handleThemeChange,
                ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOcean.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOcean),
              ),
              const SizedBox(height: 24),
              Text(
                'Gathering words worth keeping...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Brewing a fresh batch of inspiration',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NameSetupScreen extends StatefulWidget {
  final Function(QuoteReader) onReaderCreated;

  const NameSetupScreen({super.key, required this.onReaderCreated});

  @override
  State<NameSetupScreen> createState() => _NameSetupScreenState();
}

class _NameSetupScreenState extends State<NameSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _isSaving = false;

  Future<void> _createReader() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a name to begin reading.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final reader = QuoteReader(
        name: name,
        createdAt: DateTime.now(),
      );
      final id = await _dbService.insertReader(reader);
      final createdReader = QuoteReader(
        id: id,
        name: reader.name,
        createdAt: reader.createdAt,
      );
      if (!mounted) return;
      widget.onReaderCreated(createdReader);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'quote_logo',
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOcean.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Quote Garden',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome, Reader!',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pick a name so we can keep your favorite quotes close.',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: AppTheme.cardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reader Name',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Jade, River, Stella...',
                          prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryOcean.withOpacity(0.8)),
                        ),
                        textCapitalization: TextCapitalization.words,
                        enabled: !_isSaving,
                        onSubmitted: (_) => _createReader(),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppTheme.subtleCardDecoration,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppTheme.secondaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.auto_stories, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You can add more readers later. For now, choose any name you love.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _createReader,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.favorite_outline),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Start Reading',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  final QuoteReader reader;
  final AppThemeMode themeMode;
  final Function(AppThemeMode, bool) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.reader,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _recentMemory = 6;

  final DatabaseService _dbService = DatabaseService();
  final SettingsService _settingsService = SettingsService();
  final ListQueue<int> _recentQuoteIds = ListQueue<int>();
  final Random _random = Random();

  Quote _currentQuote = getRandomQuote();
  bool _favoriteMode = false;
  bool _isFavorite = false;
  bool _isLoadingQuote = false;
  List<FavoriteQuote> _favorites = const [];

  @override
  void initState() {
    super.initState();
    _recentQuoteIds.addLast(_currentQuote.id);
    _hydrateState();
    _updateReadingStreak();
  }

  Future<void> _updateReadingStreak() async {
    await _settingsService.init();
    await _settingsService.updateReadingStreak();
    await _settingsService.incrementQuoteView(_currentQuote.id);
  }

  Future<void> _hydrateState() async {
    if (widget.reader.id == null) return;
    final favorites = await _dbService.getFavoriteQuotes(widget.reader.id!);
    final isFavorite = await _dbService.isQuoteFavorited(
      userId: widget.reader.id!,
      quoteId: _currentQuote.id,
    );

    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _isFavorite = isFavorite;
    });
  }

  Future<void> _refreshQuote() async {
    if (_isLoadingQuote) return;
    setState(() {
      _isLoadingQuote = true;
    });

    Quote nextQuote;
    final Set<int> exclusions = _recentQuoteIds.toSet();

    if (_favoriteMode && _favorites.isNotEmpty) {
      final List<FavoriteQuote> pool = _favorites
          .where((fav) => !exclusions.contains(fav.quoteId))
          .toList();

      final FavoriteQuote selection = (pool.isNotEmpty ? pool : _favorites)
          [_random.nextInt((pool.isNotEmpty ? pool : _favorites).length)];
      nextQuote = Quote(
        id: selection.quoteId,
        text: selection.quoteText,
        author: selection.quoteAuthor,
      );
    } else {
      nextQuote = getRandomQuote(excludeIds: exclusions);
    }

    bool isFavorite = _isFavorite;
    if (widget.reader.id != null) {
      isFavorite = await _dbService.isQuoteFavorited(
        userId: widget.reader.id!,
        quoteId: nextQuote.id,
      );
    }

    if (!mounted) return;
    setState(() {
      _currentQuote = nextQuote;
      _isFavorite = isFavorite;
      _isLoadingQuote = false;
      _recentQuoteIds.addLast(nextQuote.id);
      while (_recentQuoteIds.length > _recentMemory) {
        _recentQuoteIds.removeFirst();
      }
    });
  }

  Future<void> _toggleFavoriteMode(bool value) async {
    if (value && _favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a few favorites before activating favorite mode.')),
      );
      return;
    }

    setState(() {
      _favoriteMode = value;
    });
    await _refreshQuote();
  }

  Future<void> _toggleFavorite() async {
    if (widget.reader.id == null) return;
    final readerId = widget.reader.id!;

    try {
      if (_isFavorite) {
        await _dbService.removeFavoriteQuote(
          userId: readerId,
          quoteId: _currentQuote.id,
        );
      } else {
        await _dbService.upsertFavoriteQuote(
          FavoriteQuote(
            userId: readerId,
            quoteId: _currentQuote.id,
            quoteText: _currentQuote.text,
            quoteAuthor: _currentQuote.author,
            createdAt: DateTime.now(),
          ),
        );
      }

      final favorites = await _dbService.getFavoriteQuotes(readerId);
      final isFavorite = await _dbService.isQuoteFavorited(
        userId: readerId,
        quoteId: _currentQuote.id,
      );

      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _isFavorite = isFavorite;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update favorites: $e')),
      );
    }
  }

  Future<void> _openQuoteExplorer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuoteExplorerScreen(
          reader: widget.reader,
          startInFavoriteMode: _favoriteMode,
        ),
      ),
    );

    if (!mounted) return;
    await _hydrateState();
  }

  Future<void> _openFavorites() async {
    final QuoteReader? reader = await Navigator.of(context).push<QuoteReader>(
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(reader: widget.reader),
      ),
    );

    if (!mounted) return;

    if (reader != null && reader.id != null && reader.id != widget.reader.id) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            reader: reader,
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
      return;
    }

    await _hydrateState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildQuoteCard(context),
              const SizedBox(height: 16),
              _buildControls(context),
              const SizedBox(height: 24),
              _buildActionRow(context),
              const SizedBox(height: 24),
              _buildInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.reader.name}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _favoriteMode ? 'Favorite mode is on' : 'Discover something worth saving',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StatisticsScreen(
                  themeMode: widget.themeMode,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryGradientForMode(widget.themeMode),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.insights, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    final String attribution = _currentQuote.source == null
        ? _currentQuote.author
        : '${_currentQuote.author} • ${_currentQuote.source}';

    final gradient = AppTheme.getPrimaryGradientForMode(widget.themeMode);
    final primaryColor = AppTheme.getPrimaryColorForMode(widget.themeMode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Daily Highlight',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '“${_currentQuote.text}”',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    attribution,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    await QuoteShareHelper.showStyleSelector(
                      context,
                      _currentQuote,
                      themeMode: widget.themeMode,
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Share quote',
                ),
                IconButton(
                  onPressed: widget.reader.id == null ? null : _toggleFavorite,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(_isFavorite),
                      color: Colors.white,
                    ),
                  ),
                  tooltip: 'Save to favorites',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final favoritesCount = _favorites.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite mode',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favoritesCount == 0
                          ? 'Save a quote to unlock favorite-only shuffle.'
                          : '$favoritesCount saved ${favoritesCount == 1 ? 'quote' : 'quotes'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _favoriteMode,
                activeColor: AppTheme.primaryOcean,
                onChanged: widget.reader.id == null ? null : _toggleFavoriteMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingQuote ? null : _refreshQuote,
              icon: _isLoadingQuote
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.autorenew_rounded),
              label: Text(
                _favoriteMode ? 'Next favorite quote' : 'Shuffle quote',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            title: 'Favorites Library',
            subtitle: 'Browse saved quotes',
            icon: Icons.favorite_outline,
            gradient: AppTheme.secondaryGradient,
            onTap: _openFavorites,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionTile(
            title: 'Explore Quotes',
            subtitle: 'Dive into random lines',
            icon: Icons.auto_stories,
            gradient: LinearGradient(
              colors: [AppTheme.accentSunrise.withOpacity(0.8), AppTheme.accentSunrise],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: _openQuoteExplorer,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reading Rituals',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.subtleCardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.wb_twighlight, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Morning spark',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start the day with a quote shuffle and note the line that resonates most.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOcean.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.edit_note, color: AppTheme.primaryOcean),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: revisit your favorites each week and write why each line mattered to you.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
