import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/prompt_card.dart';
import '../theme/app_theme.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  Category _category = Category.all;
  SortOrder _sort = SortOrder.trending;
  String? _activeTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _parseViewCount(String s) {
    final clean = s.toLowerCase().replaceAll(',', '').trim();
    if (clean.endsWith('k')) return ((double.tryParse(clean.replaceAll('k', '')) ?? 0) * 1000).toInt();
    if (clean.endsWith('m')) return ((double.tryParse(clean.replaceAll('m', '')) ?? 0) * 1000000).toInt();
    return int.tryParse(clean) ?? 0;
  }

  List<PromptItem> _filter(MarketplaceProvider provider) {
    var list = List<PromptItem>.from(provider.sortedPrompts);

    if (_category != Category.all) {
      list = list.where((p) => p.category == _category).toList();
    }
    if (_activeTag != null) {
      list = list.where((p) => p.tags.contains(_activeTag)).toList();
    }
    final q = _searchController.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    switch (_sort) {
      case SortOrder.mostLiked:
        list.sort((a, b) => b.likes.compareTo(a.likes));
      case SortOrder.mostViewed:
        list.sort((a, b) => _parseViewCount(b.viewsCount).compareTo(_parseViewCount(a.viewsCount)));
      case SortOrder.newest:
        list = list.reversed.toList();
      case SortOrder.trending:
        list.sort((a, b) {
          if (a.isTrendingNow && !b.isTrendingNow) return -1;
          if (!a.isTrendingNow && b.isTrendingNow) return 1;
          return 0;
        });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet =
        MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final filtered = _filter(provider);
    final crossCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surfaceContainerHigh,
      onRefresh: () => provider.refresh(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _Header(
              searchController: _searchController,
              provider: provider,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: Category.values.map((c) {
                  final selected = _category == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _category = c;
                        _activeTag = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary
                              : colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: selected
                                ? colors.primary
                                : colors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          c.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Sort + result count row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.isLoading
                      ? 'Loading...'
                      : '${filtered.length} prompts',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                PopupMenuButton<SortOrder>(
                  color: colors.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  onSelected: (o) => setState(() => _sort = o),
                  itemBuilder: (_) => SortOrder.values
                      .map((o) => PopupMenuItem(
                            value: o,
                            child: Row(
                              children: [
                                Icon(o.icon,
                                    size: 15,
                                    color: _sort == o
                                        ? colors.primary
                                        : colors.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Text(
                                  o.label,
                                  style: TextStyle(
                                    color: _sort == o
                                        ? colors.primary
                                        : colors.onSurface,
                                    fontWeight: _sort == o
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_sort.icon, size: 14, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _sort.label,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.primary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more_rounded,
                            size: 14, color: colors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tag cloud
            if (!provider.isLoading && provider.allTags.isNotEmpty) ...[
              _TagCloud(
                tags: provider.allTags,
                activeTag: _activeTag,
                onTap: (tag) => setState(
                    () => _activeTag = _activeTag == tag ? null : tag),
              ),
              const SizedBox(height: 24),
            ],

            // Grid
            if (provider.loadError != null && !provider.isLoading)
              _ErrorState(onRetry: () => provider.refresh())
            else if (provider.isLoading)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: crossCount * 3,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 245,
                ),
                itemBuilder: (_, __) => SkeletonPromptCard(),
              )
            else if (filtered.isEmpty)
              _EmptyState(
                hasSearch: _searchController.text.isNotEmpty || _activeTag != null,
                onClear: () => setState(() {
                  _searchController.clear();
                  _category = Category.all;
                  _activeTag = null;
                }),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 245,
                ),
                itemBuilder: (_, i) => PromptCard(prompt: filtered[i]),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController searchController;
  final MarketplaceProvider provider;
  final VoidCallback onChanged;

  const _Header({
    required this.searchController,
    required this.provider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardGlassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardGlassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.secondaryContainer.withValues(alpha: 0.15),
                  border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.explore_rounded,
                    size: 18, color: colors.secondary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Library',
                    style: GoogleFonts.sora(
                      fontSize: AppSizes.of(context).h2,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    'Search across all community curated prompts',
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.of(context).body,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.2)),
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: colors.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search prompts, tags, creators...',
                hintStyle: TextStyle(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: colors.secondary, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: colors.onSurfaceVariant, size: 18),
                        onPressed: () {
                          searchController.clear();
                          onChanged();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) provider.addRecentSearch(val.trim());
              },
            ),
          ),

          // Recent searches
          if (provider.recentSearches.isNotEmpty &&
              searchController.text.isEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: provider.clearRecentSearches,
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.secondary.withValues(alpha: 0.7),
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
                        searchController.text = q;
                        onChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                                size: 12,
                                color: colors.onSurfaceVariant
                                    .withValues(alpha: 0.5)),
                            const SizedBox(width: 5),
                            Text(q,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant)),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => provider.removeRecentSearch(q),
                              child: Icon(Icons.close_rounded,
                                  size: 12,
                                  color: colors.onSurfaceVariant
                                      .withValues(alpha: 0.4)),
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
        ],
      ),
    );
  }
}

class _TagCloud extends StatelessWidget {
  final List<String> tags;
  final String? activeTag;
  final void Function(String) onTap;

  const _TagCloud(
      {required this.tags, required this.activeTag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by tag',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.take(30).map((tag) {
            final active = activeTag == tag;
            return GestureDetector(
              onTap: () => onTap(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? colors.secondary.withValues(alpha: 0.15)
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? colors.secondary.withValues(alpha: 0.5)
                        : colors.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: active
                        ? colors.secondary
                        : colors.onSurfaceVariant,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.cardGlassBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 40, color: colors.tertiary),
              const SizedBox(height: 16),
              Text('Failed to Load',
                  style: GoogleFonts.sora(
                      fontSize: 17, fontWeight: FontWeight.w600, color: colors.onSurface)),
              const SizedBox(height: 8),
              Text('Something went wrong. Pull down to retry.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 15, color: colors.tertiary),
                      const SizedBox(width: 8),
                      Text('Try Again',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: colors.tertiary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onClear;

  const _EmptyState({required this.hasSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.cardGlassBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.secondaryContainer.withValues(alpha: 0.1),
                  border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.25),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.secondary.withValues(alpha: 0.12),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(Icons.search_off_rounded,
                    size: 32, color: colors.secondary),
              ),
              const SizedBox(height: 18),
              Text(
                'No Results Found',
                style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                hasSearch
                    ? 'Try different keywords or remove active filters.'
                    : 'No prompts match the selected category.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.5),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 15, color: colors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Clear Filters',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
