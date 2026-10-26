import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/math_questions.dart';
import '../models/quote.dart';
import '../models/fav_quote.dart';
import '../models/reader.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

enum FavoriteSortMode { newest, oldest, author }

class FavoritesScreen extends StatefulWidget {
  final QuoteReader reader;

  const FavoritesScreen({super.key, required this.reader});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static final DateFormat _timestampFormat = DateFormat('MMM dd, yyyy • HH:mm');

  final DatabaseService _dbService = DatabaseService();
  late QuoteReader _selectedReader;

  List<QuoteReader> _readers = const [];
  List<FavoriteQuote> _favorites = const [];
  List<FavoriteQuote> _filteredFavorites = const [];
  Set<int> _favoriteIds = <int>{};

  String _searchQuery = '';
  FavoriteSortMode _sortMode = FavoriteSortMode.newest;
  bool _isLoading = true;
  bool _isLoadingReaders = true;

  @override
  void initState() {
    super.initState();
    _selectedReader = widget.reader;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadReaders(),
      _loadFavoritesForReader(_selectedReader),
    ]);
  }

  Future<void> _loadReaders() async {
    final readers = await _dbService.getAllReaders();
    if (!mounted) return;

    setState(() {
      _readers = readers;
      _isLoadingReaders = false;
    });
  }

  Future<void> _loadFavoritesForReader(QuoteReader reader) async {
    if (reader.id == null) {
      if (!mounted) return;
      setState(() {
        _favorites = const [];
        _filteredFavorites = const [];
        _favoriteIds = <int>{};
        _isLoading = false;
      });
      return;
    }

    final favorites = await _dbService.getFavoriteQuotes(reader.id!);
    final filtered = _applyFilters(
      favorites: favorites,
      query: _searchQuery,
      sortMode: _sortMode,
    );

    if (!mounted) return;

    setState(() {
      _favorites = favorites;
      _filteredFavorites = filtered;
      _favoriteIds = favorites.map((fav) => fav.quoteId).toSet();
      _isLoading = false;
    });
  }

  List<FavoriteQuote> _applyFilters({
    required List<FavoriteQuote> favorites,
    required String query,
    required FavoriteSortMode sortMode,
  }) {
    Iterable<FavoriteQuote> filtered = favorites;
    final normalized = query.trim().toLowerCase();

    if (normalized.isNotEmpty) {
      filtered = filtered.where((favorite) {
        final quote = _resolveQuote(favorite);
        return quote.text.toLowerCase().contains(normalized) ||
            quote.author.toLowerCase().contains(normalized) ||
            (quote.source?.toLowerCase().contains(normalized) ?? false);
      });
    }

    final List<FavoriteQuote> result = filtered.toList();
    switch (sortMode) {
      case FavoriteSortMode.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case FavoriteSortMode.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case FavoriteSortMode.author:
        result.sort((a, b) {
          final authorA = _resolveQuote(a).author.toLowerCase();
          final authorB = _resolveQuote(b).author.toLowerCase();
          final compare = authorA.compareTo(authorB);
          if (compare != 0) return compare;
          return a.createdAt.compareTo(b.createdAt);
        });
        break;
    }

    return result;
  }

  Quote _resolveQuote(FavoriteQuote favorite) {
    final original = getQuoteById(favorite.quoteId);
    if (original != null) {
      return original;
    }

    return Quote(
      id: favorite.quoteId,
      text: favorite.quoteText,
      author: favorite.quoteAuthor,
    );
  }

  void _onSearchChanged(String value) {
    final filtered = _applyFilters(
      favorites: _favorites,
      query: value,
      sortMode: _sortMode,
    );

    setState(() {
      _searchQuery = value;
      _filteredFavorites = filtered;
    });
  }

  void _onSortModeChanged(FavoriteSortMode mode) {
    if (_sortMode == mode) return;
    final filtered = _applyFilters(
      favorites: _favorites,
      query: _searchQuery,
      sortMode: mode,
    );

    setState(() {
      _sortMode = mode;
      _filteredFavorites = filtered;
    });
  }

  Future<void> _removeFavorite(FavoriteQuote favorite) async {
    try {
      await _dbService.removeFavoriteQuote(
        userId: favorite.userId,
        quoteId: favorite.quoteId,
      );

      final updatedFavorites = List<FavoriteQuote>.from(_favorites)
        ..removeWhere((fav) => fav.quoteId == favorite.quoteId);
      final updatedIds = Set<int>.from(_favoriteIds)..remove(favorite.quoteId);
      final filtered = _applyFilters(
        favorites: updatedFavorites,
        query: _searchQuery,
        sortMode: _sortMode,
      );

      if (!mounted) return;

      setState(() {
        _favorites = updatedFavorites;
        _favoriteIds = updatedIds;
        _filteredFavorites = filtered;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote removed from favorites.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove favorite: $e')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _loadFavoritesForReader(_selectedReader);
  }

  void _showReaderPicker() {
    if (_isLoadingReaders || _readers.length <= 1) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose reader',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._readers.map((reader) {
                final bool isActive = reader.id == _selectedReader.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryOcean.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryOcean,
                    child: Text(reader.name[0].toUpperCase()),
                  ),
                  title: Text(
                    reader.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  trailing: isActive ? const Icon(Icons.check, color: AppTheme.primaryOcean) : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isActive) {
                      _selectReader(reader);
                    }
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _selectReader(QuoteReader reader) {
    setState(() {
      _selectedReader = reader;
      _isLoading = true;
      _searchQuery = '';
    });
    _loadFavoritesForReader(reader);
  }

  String _sortLabel(FavoriteSortMode mode) {
    switch (mode) {
      case FavoriteSortMode.newest:
        return 'Newest';
      case FavoriteSortMode.oldest:
        return 'Oldest';
      case FavoriteSortMode.author:
        return 'Author A-Z';
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
                    : _buildFavoritesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOcean.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(_selectedReader),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorites Library',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                    const SizedBox(height: 4),
                    Text(
                      _filteredFavorites.isEmpty
                          ? 'No saved quotes yet. Start building your collection.'
                          : '${_filteredFavorites.length} saved ${_filteredFavorites.length == 1 ? "quote" : "quotes"}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _readers.length <= 1 ? null : _showReaderPicker,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
                tooltip: _readers.length <= 1 ? 'Only one reader available' : 'Switch reader',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedReader.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search saved quotes, authors, or sources',
            prefixIcon: Icon(Icons.search, color: AppTheme.primaryOcean.withOpacity(0.6)),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _onSearchChanged('');
                    },
                    icon: const Icon(Icons.clear),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FavoriteSortMode.values.map((mode) {
              final bool selected = _sortMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_sortLabel(mode)),
                  selected: selected,
                  onSelected: (_) => _onSortModeChanged(mode),
                  selectedColor: AppTheme.primaryOcean.withOpacity(0.2),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppTheme.primaryOcean : AppTheme.textSecondary,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: selected ? AppTheme.primaryOcean : const Color(0xFFE2ECF4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesList() {
    if (_filteredFavorites.isEmpty) {
      final bool isSearching = _searchQuery.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.favorite_border, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                isSearching ? 'No matching quotes' : 'Your shelf is empty',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
              const SizedBox(height: 8),
                          Text(
                isSearching
                    ? 'Try refining your keywords or clearing the search bar.'
                    : 'Tap the heart on any quote to collect it here.',
                            style: GoogleFonts.poppins(
                  fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Discover quotes'),
                          ),
                        ],
                      ),
                    ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryOcean,
      onRefresh: _handleRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _filteredFavorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final favorite = _filteredFavorites[index];
          final quote = _resolveQuote(favorite);
          final String timestamp = _timestampFormat.format(favorite.createdAt);
          final bool isAligned = index.isEven;

          return Align(
            alignment: isAligned ? Alignment.centerLeft : Alignment.centerRight,
            child: _FavoriteCard(
              quote: quote,
              savedOn: timestamp,
              onRemove: () => _removeFavorite(favorite),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Quote quote;
  final String savedOn;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.quote,
    required this.savedOn,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final attribution = quote.source == null ? quote.author : '${quote.author} • ${quote.source}';

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOcean.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.favorite, color: AppTheme.primaryOcean),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove from favorites',
                  icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
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
            const SizedBox(height: 8),
          Text(
              'Saved $savedOn',
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
