import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/prompt_card.dart';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({super.key});

  @override
  State<TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView> {
  Category _selectedMediaCategory = Category.all;
  String _selectedModelTag = 'GPT-4';
  late TextEditingController _searchController;
  Timer? _debounce;

  final List<Map<String, dynamic>> _mediaChips = [
    {'category': Category.all, 'label': 'All Media', 'icon': Icons.auto_awesome_rounded},
    {'category': Category.video, 'label': 'Video', 'icon': Icons.videocam_rounded},
    {'category': Category.image, 'label': 'Image', 'icon': Icons.image_rounded},
    {'category': Category.web, 'label': 'Web Page', 'icon': Icons.language_rounded},
  ];

  final List<String> _modelChips = [
    'GPT-4',
    'Gemini Pro',
    'Nano Banana',
    'Claude 3',
    'Midjourney v6',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final colors = AppColors.of(context);

    // Keep controller in sync with provider search query
    if (_searchController.text != provider.searchQuery) {
      _searchController.text = provider.searchQuery;
    }

    // Filter prompts based on selected media category and search query
    final filteredPrompts = provider.sortedPrompts.where((prompt) {
      if (_selectedMediaCategory != Category.all &&
          prompt.category != _selectedMediaCategory) {
        return false;
      }
      if (provider.searchQuery.isNotEmpty) {
        final query = provider.searchQuery.toLowerCase();
        final matchesTitle = prompt.title.toLowerCase().contains(query);
        final matchesDesc = prompt.description.toLowerCase().contains(query);
        final matchesTags =
            prompt.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesTitle && !matchesDesc && !matchesTags) return false;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surfaceContainerHigh,
      onRefresh: () => provider.refresh(),
      child: _buildBody(context, colors, provider, isDesktop, isTablet, filteredPrompts),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    MarketplaceProvider provider,
    bool isDesktop,
    bool isTablet,
    List<PromptItem> filteredPrompts,
  ) {
    return Stack(
      children: [
        // Ambient Radial Glow matching HTML design
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          height: 400,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 0.8,
                colors: [
                  colors.primary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. HERO BANNER WITH BACKGROUND IMAGE (LOW OPACITY)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.cardGlassBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Low Opacity Background Image
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.25,
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Dark Gradient Overlay for Optimal Readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.background.withValues(alpha: 0.85),
                              colors.background.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),

                    // Banner Content Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rainbow Accent Line
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors.primary,
                                colors.secondary,
                                colors.tertiary,
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : (isTablet ? 20 : 14),
                            vertical: isDesktop ? 32 : 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stats row
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _StatBadge(label: '30,000+ PROMPTS', icon: Icons.bolt_rounded, colors: colors),
                                  _StatBadge(label: 'UPDATED DAILY', icon: Icons.sync_rounded, colors: colors),
                                  _StatBadge(label: '100% FREE', icon: Icons.lock_open_rounded, colors: colors),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Heading
                              Text(
                                'AI Prompt\nLibrary',
                                style: GoogleFonts.sora(
                                  fontSize: isDesktop ? 36 : (isTablet ? 28 : AppSizes.of(context).h1),
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Subtitle
                              Text(
                                'Explore hot and trending AI prompts for image, video, and webpage generation. Continuously tracking the latest models, with new prompts every day.',
                                style: GoogleFonts.inter(
                                  fontSize: isDesktop ? 15 : AppSizes.of(context).body,
                                  color: colors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 0.5. SEARCH BAR (MOVED OUT BELOW BANNER)
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () {
                      provider.setSearchQuery(val);
                    });
                  },
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      provider.addRecentSearch(val.trim());
                      AnalyticsService.logSearch(val.trim());
                    }
                  },
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search 2,400+ AI prompts, models or tags...',
                    hintStyle: TextStyle(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: colors.onSurfaceVariant,
                              size: 16,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // Recent searches
              if (provider.recentSearches.isNotEmpty && provider.searchQuery.isEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent searches',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: provider.clearRecentSearches,
                      child: Text(
                        'Clear all',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: provider.recentSearches.map((q) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _searchController.text = q;
                            provider.setSearchQuery(q);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 13,
                                    color: colors.onSurfaceVariant
                                        .withValues(alpha: 0.6)),
                                const SizedBox(width: 6),
                                Text(
                                  q,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => provider.removeRecentSearch(q),
                                  child: Icon(Icons.close_rounded,
                                      size: 13,
                                      color: colors.onSurfaceVariant
                                          .withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // 1. HEADER ROW: "Trending Now" & sort button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Now',
                    style: GoogleFonts.sora(
                      fontSize: AppSizes.of(context).h2,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  PopupMenuButton<SortOrder>(
                    color: colors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    onSelected: provider.setSortOrder,
                    itemBuilder: (_) => SortOrder.values
                        .map((o) => PopupMenuItem(
                              value: o,
                              child: Row(
                                children: [
                                  Icon(o.icon,
                                      size: 16,
                                      color: provider.sortOrder == o
                                          ? colors.primary
                                          : colors.onSurfaceVariant),
                                  const SizedBox(width: 10),
                                  Text(
                                    o.label,
                                    style: TextStyle(
                                      color: provider.sortOrder == o
                                          ? colors.primary
                                          : colors.onSurface,
                                      fontWeight: provider.sortOrder == o
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: colors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(provider.sortOrder.icon,
                              size: 15, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            provider.sortOrder.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more_rounded,
                              size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. MEDIA TYPE CHIPS ROW
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _mediaChips.map((chip) {
                    final cat = chip['category'] as Category;
                    final label = chip['label'] as String;
                    final icon = chip['icon'] as IconData;
                    final isSelected = _selectedMediaCategory == cat;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedMediaCategory = cat);
                          provider.setActiveCategory(cat);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary
                                : colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 3. MODEL SELECTION CHIPS ROW
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _modelChips.map((model) {
                    final isSelected = _selectedModelTag == model;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ActionChip(
                        label: Text(model),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? colors.secondary
                              : colors.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: isSelected
                            ? colors.secondaryContainer.withValues(alpha: 0.15)
                            : colors.surfaceContainerLow,
                        side: BorderSide(
                          color: isSelected
                              ? colors.secondary
                              : colors.outline.withValues(alpha: 0.15),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          setState(() => _selectedModelTag = model);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // 4. PROMPT GRID
              if (provider.loadError != null && !provider.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colors.cardGlassBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.tertiary.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 44, color: colors.tertiary),
                          const SizedBox(height: 16),
                          Text('Failed to load prompts',
                              style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
                          const SizedBox(height: 8),
                          Text(provider.loadError!, textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: provider.refresh,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Retry'),
                            style: FilledButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (provider.isLoading)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: crossAxisCount * 3,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        mainAxisExtent: 245,
                      ),
                      itemBuilder: (context, index) => SkeletonPromptCard(),
                    );
                  },
                )
              else if (filteredPrompts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                      decoration: BoxDecoration(
                        color: colors.cardGlassBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.cardGlassBorder, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon container with glow
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primaryContainer.withValues(alpha: 0.12),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Prompts Found',
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'No results for "${provider.searchQuery}".\nTry different keywords or clear the search.'
                                : 'No prompts match the selected filters.\nTry a different category or model.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Clear filters button
                          InkWell(
                            onTap: () {
                              setState(() => _selectedMediaCategory = Category.all);
                              provider.setActiveCategory(Category.all);
                              provider.setSearchQuery('');
                              _searchController.clear();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 16, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Clear Filters',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPrompts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        mainAxisExtent: 245,
                      ),
                      itemBuilder: (context, index) {
                        return PromptCard(prompt: filteredPrompts[index]);
                      },
                    );
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppColors colors;

  const _StatBadge({required this.label, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.primary,
              fontSize: AppSizes.of(context).caption,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
