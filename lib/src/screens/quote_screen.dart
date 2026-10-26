import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/math_questions.dart';
import '../models/quote.dart';
import '../models/fav_quote.dart';
import '../models/reader.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class QuoteExplorerScreen extends StatefulWidget {
  final QuoteReader reader;
  final bool startInFavoriteMode;

  const QuoteExplorerScreen({
    super.key,
    required this.reader,
    this.startInFavoriteMode = false,
  });

  @override
  State<QuoteExplorerScreen> createState() => _QuoteExplorerScreenState();
}

class _QuoteExplorerScreenState extends State<QuoteExplorerScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Quote> _browseQuotes = const [];
  List<Quote> _displayedQuotes = const [];
  List<FavoriteQuote> _favoriteQuotes = const [];
  Set<int> _favoriteQuoteIds = <int>{};
  bool _isLoading = true;
  bool _showOnlyFavorites = false;
  String _searchQuery = '';

  bool get _canPersistFavorites => widget.reader.id != null;

  @override
  void initState() {
    super.initState();
    _showOnlyFavorites = widget.startInFavoriteMode;
    _hydrate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    List<FavoriteQuote> favorites = const [];
    if (_canPersistFavorites) {
      favorites = await _dbService.getFavoriteQuotes(widget.reader.id!);
    }

    final List<Quote> browseQuotes = getRandomQuotes(
      24,
      excludeIds: _showOnlyFavorites ? _favoriteQuoteIds : null,
    );
    final Set<int> favoriteIds = favorites.map((fav) => fav.quoteId).toSet();
    final bool showFavorites = _showOnlyFavorites && favorites.isNotEmpty && _canPersistFavorites;
    final List<Quote> resolved = _resolveDisplayQuotes(
      showFavorites: showFavorites,
      searchQuery: _searchQuery,
      browseQuotes: browseQuotes,
      favorites: favorites,
    );

    if (!mounted) return;

    setState(() {
      _favoriteQuotes = favorites;
      _favoriteQuoteIds = favoriteIds;
      _browseQuotes = browseQuotes;
      _showOnlyFavorites = showFavorites;
      _displayedQuotes = resolved;
      _isLoading = false;
    });
  }

  List<Quote> _resolveDisplayQuotes({
    required bool showFavorites,
    required String searchQuery,
    required List<Quote> browseQuotes,
    required List<FavoriteQuote> favorites,
  }) {
    final String normalized = searchQuery.trim().toLowerCase();

    if (showFavorites) {
      List<Quote> base = favorites.map(_favoriteToQuote).toList();
      if (normalized.isEmpty) {
        return base;
      }
      base = base.where((quote) => _matchesQuery(quote, normalized)).toList();
      return base;
    }

    if (normalized.isNotEmpty) {
      return searchQuotes(searchQuery, limit: 80);
    }

    return browseQuotes;
  }

  Quote _favoriteToQuote(FavoriteQuote favorite) {
    final Quote? original = getQuoteById(favorite.quoteId);
    if (original != null) {
      return original;
    }

    return Quote(
      id: favorite.quoteId,
      text: favorite.quoteText,
      author: favorite.quoteAuthor,
    );
  }

  bool _matchesQuery(Quote quote, String normalized) {
    return quote.text.toLowerCase().contains(normalized) ||
        quote.author.toLowerCase().contains(normalized) ||
        (quote.source?.toLowerCase().contains(normalized) ?? false);
  }

  void _onSearchChanged(String value) {
    final String nextQuery = value;
    final List<Quote> resolved = _resolveDisplayQuotes(
      showFavorites: _showOnlyFavorites,
      searchQuery: nextQuery,
      browseQuotes: _browseQuotes,
      favorites: _favoriteQuotes,
    );

    setState(() {
      _searchQuery = nextQuery;
      _displayedQuotes = resolved;
    });
  }

  void _toggleFavoriteFilter(bool value) {
    if (value) {
      if (!_canPersistFavorites) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create a reader profile to save favorites.')),
        );
        return;
      }

      if (_favoriteQuotes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add favorites before enabling favorite mode.')),
        );
        return;
      }
    }

    final List<Quote> resolved = _resolveDisplayQuotes(
      showFavorites: value,
      searchQuery: _searchQuery,
      browseQuotes: _browseQuotes,
      favorites: _favoriteQuotes,
    );

    setState(() {
      _showOnlyFavorites = value;
      _displayedQuotes = resolved;
    });
  }

  Future<void> _shuffleBrowseQuotes() async {
    final List<Quote> nextBrowse = getRandomQuotes(
      24,
      excludeIds: _favoriteQuoteIds,
    );
    final List<Quote> resolved = _resolveDisplayQuotes(
      showFavorites: _showOnlyFavorites,
      searchQuery: _searchQuery,
      browseQuotes: nextBrowse,
      favorites: _favoriteQuotes,
    );

    if (!mounted) return;

    setState(() {
      _browseQuotes = nextBrowse;
      _displayedQuotes = resolved;
    });
  }

  Future<void> _refreshFavorites() async {
    if (!_canPersistFavorites) return;
    final List<FavoriteQuote> favorites = await _dbService.getFavoriteQuotes(widget.reader.id!);
    final Set<int> ids = favorites.map((fav) => fav.quoteId).toSet();
    final bool showFavorites = _showOnlyFavorites && favorites.isNotEmpty;
    final List<Quote> resolved = _resolveDisplayQuotes(
      showFavorites: showFavorites,
      searchQuery: _searchQuery,
      browseQuotes: _browseQuotes,
      favorites: favorites,
    );

    if (!mounted) return;

    setState(() {
      _favoriteQuotes = favorites;
      _favoriteQuoteIds = ids;
      _showOnlyFavorites = showFavorites;
      _displayedQuotes = resolved;
    });
  }

  Future<void> _toggleFavorite(Quote quote) async {
    if (!_canPersistFavorites) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a reader profile to save favorites.')),
      );
      return;
    }

    final int readerId = widget.reader.id!;
    final bool isFavorite = _favoriteQuoteIds.contains(quote.id);

    try {
      late List<FavoriteQuote> updatedFavorites;
      late Set<int> updatedIds;

      if (isFavorite) {
        await _dbService.removeFavoriteQuote(userId: readerId, quoteId: quote.id);
        updatedFavorites = List<FavoriteQuote>.from(_favoriteQuotes)
          ..removeWhere((fav) => fav.quoteId == quote.id);
        updatedIds = Set<int>.from(_favoriteQuoteIds)..remove(quote.id);
      } else {
        final FavoriteQuote favorite = FavoriteQuote(
          userId: readerId,
          quoteId: quote.id,
          quoteText: quote.text,
          quoteAuthor: quote.author,
          createdAt: DateTime.now(),
        );
        final int insertedId = await _dbService.upsertFavoriteQuote(favorite);
        final FavoriteQuote stored = FavoriteQuote(
          id: insertedId,
          userId: readerId,
          quoteId: quote.id,
          quoteText: quote.text,
          quoteAuthor: quote.author,
          createdAt: favorite.createdAt,
        );
        updatedFavorites = [stored, ..._favoriteQuotes];
        updatedIds = Set<int>.from(_favoriteQuoteIds)..add(quote.id);
      }

      final bool shouldDisableFavoriteView = _showOnlyFavorites && updatedFavorites.isEmpty;
      final bool nextShowFavorites = shouldDisableFavoriteView ? false : _showOnlyFavorites;
      final List<Quote> resolved = _resolveDisplayQuotes(
        showFavorites: nextShowFavorites,
        searchQuery: _searchQuery,
        browseQuotes: _browseQuotes,
        favorites: updatedFavorites,
      );

      if (!mounted) return;

      setState(() {
        _favoriteQuotes = updatedFavorites;
        _favoriteQuoteIds = updatedIds;
        _showOnlyFavorites = nextShowFavorites;
        _displayedQuotes = resolved;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update favorites: $e')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    if (_showOnlyFavorites) {
      await _refreshFavorites();
    } else {
      await _shuffleBrowseQuotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildControls(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOcean),
                        ),
                      )
                    : _buildQuoteList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
              color: Colors.white,
          borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                'Explore Quotes',
            style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
          Text(
                _showOnlyFavorites
                    ? 'Browsing your saved inspirations.'
                    : 'Shuffle through 300 curated lines.',
            style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: _showOnlyFavorites ? 'Favorites view' : 'Shuffle quotes',
          child: IconButton(
            onPressed: _showOnlyFavorites ? null : _shuffleBrowseQuotes,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.auto_awesome, color: AppTheme.primaryOcean),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search quotes, authors, or sources',
            prefixIcon: Icon(Icons.search, color: AppTheme.primaryOcean.withOpacity(0.6)),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 12),
          Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: AppTheme.cardDecoration.copyWith(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
          Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite mode',
              style: GoogleFonts.poppins(
                        fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
                    const SizedBox(height: 4),
                    Text(
                      !_canPersistFavorites
                          ? 'Create a reader to start saving quotes.'
                          : _favoriteQuotes.isEmpty
                              ? 'Save a quote to unlock favorite-only browsing.'
                              : '${_favoriteQuotes.length} saved ${_favoriteQuotes.length == 1 ? "quote" : "quotes"}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _showOnlyFavorites,
                activeColor: AppTheme.primaryOcean,
                onChanged: _toggleFavoriteFilter,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteList() {
    if (_displayedQuotes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryOcean,
      onRefresh: _handleRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _displayedQuotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final Quote quote = _displayedQuotes[index];
          final bool isFavorite = _favoriteQuoteIds.contains(quote.id);
          return _QuoteCard(
            quote: quote,
            isFavorite: isFavorite,
            onToggleFavorite: () => _toggleFavorite(quote),
            favoriteEnabled: _canPersistFavorites,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.book_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? 'No quotes found' : 'No favorites yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different keyword or clear your search.'
                  : 'Save quotes while browsing to build your inspiration library.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_showOnlyFavorites && !isSearching) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _toggleFavoriteFilter(false),
                child: const Text('Return to shuffle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool favoriteEnabled;

  const _QuoteCard({
    required this.quote,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.favoriteEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final String attribution = quote.source == null ? quote.author : '${quote.author} • ${quote.source}';

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
          child: Padding(
        padding: const EdgeInsets.all(22),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOcean.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.format_quote_rounded, color: AppTheme.primaryOcean),
                ),
                const Spacer(),
                IconButton(
                  onPressed: favoriteEnabled ? onToggleFavorite : null,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isFavorite),
                      color: isFavorite ? AppTheme.primaryOcean : AppTheme.textSecondary,
                    ),
                  ),
                        ),
                      ],
                    ),
            const SizedBox(height: 16),
                          Text(
              '“${quote.text}”',
                            style: GoogleFonts.poppins(
                fontSize: 18,
                              fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
                        Text(
              attribution,
                          style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
        ),
      ),
    );
  }
}
