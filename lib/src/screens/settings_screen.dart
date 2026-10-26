import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(AppThemeMode, bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  AppThemeMode _selectedTheme = AppThemeMode.ocean;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    setState(() {
      _selectedTheme = _settingsService.getThemeMode();
      _isDarkMode = _settingsService.getDarkMode();
    });
  }

  Future<void> _changeTheme(AppThemeMode mode) async {
    setState(() => _selectedTheme = mode);
    await _settingsService.setThemeMode(mode);
    widget.onThemeChanged(mode, _isDarkMode);
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    await _settingsService.setDarkMode(value);
    widget.onThemeChanged(_selectedTheme, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildDarkModeToggle(),
          const SizedBox(height: 24),
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeGrid(),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.subtleCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dark_mode,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Easier on the eyes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDarkMode || _selectedTheme == AppThemeMode.midnight,
            onChanged: _selectedTheme == AppThemeMode.midnight
                ? null
                : _toggleDarkMode,
            activeColor: AppTheme.primaryOcean,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildThemeCard(
          'Ocean',
          '🌊',
          AppThemeMode.ocean,
          AppTheme.primaryGradient,
        ),
        _buildThemeCard(
          'Sunset',
          '🌅',
          AppThemeMode.sunset,
          AppTheme.primaryGradientSunset,
        ),
        _buildThemeCard(
          'Forest',
          '🌲',
          AppThemeMode.forest,
          AppTheme.primaryGradientForest,
        ),
        _buildThemeCard(
          'Midnight',
          '🌙',
          AppThemeMode.midnight,
          AppTheme.primaryGradientMidnight,
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    String name,
    String emoji,
    AppThemeMode mode,
    LinearGradient gradient,
  ) {
    final isSelected = _selectedTheme == mode;

    return GestureDetector(
      onTap: () => _changeTheme(mode),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white, width: 4)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryOcean.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppTheme.primaryOcean,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.subtleCardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✨',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: 12),
              Text(
                'Wisdomly MOP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Your personal sanctuary for daily inspiration. Discover, collect, and reflect on meaningful quotes with reading streaks, themed collections, and personalized insights.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Version 1.0.1',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
