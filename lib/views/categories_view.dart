import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/prompt_card.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  static const _meta = {
    Category.video: _CategoryMeta(
      label: 'Video',
      emoji: '🎬',
      description: 'Cinematic, motion & film prompts',
      gradient: [Color(0xFF6750A4), Color(0xFF2196F3)],
      icon: Icons.videocam_rounded,
    ),
    Category.image: _CategoryMeta(
      label: 'Image',
      emoji: '🖼️',
      description: 'Photography, art & illustration',
      gradient: [Color(0xFFB5004A), Color(0xFFFF6B6B)],
      icon: Icons.image_rounded,
    ),
    Category.web: _CategoryMeta(
      label: 'Web',
      emoji: '🌐',
      description: 'UI design, landing pages & apps',
      gradient: [Color(0xFF0277BD), Color(0xFF00BCD4)],
      icon: Icons.language_rounded,
    ),
    Category.code: _CategoryMeta(
      label: 'Code',
      emoji: '💻',
      description: 'Scripts, algorithms & generators',
      gradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
      icon: Icons.code_rounded,
    ),
    Category.writing: _CategoryMeta(
      label: 'Writing',
      emoji: '✍️',
      description: 'Copy, stories & content prompts',
      gradient: [Color(0xFFE65100), Color(0xFFFFB300)],
      icon: Icons.edit_note_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);

    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640 && !isDesktop;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Categories',
              style: GoogleFonts.sora(
                  fontSize: AppSizes.of(context).h1, fontWeight: FontWeight.w800, color: colors.onSurface)),
          const SizedBox(height: 4),
          Text('Browse prompts by type',
              style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant)),
          const SizedBox(height: 28),

          // Category grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 2.4 : 1.9,
            children: Category.values
                .where((c) => c != Category.all)
                .map((cat) {
              final meta = _meta[cat];
              if (meta == null) return const SizedBox.shrink();
              final count = provider.prompts
                  .where((p) => p.category == cat)
                  .length;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        _CategoryDetailPage(category: cat, meta: meta),
                    transitionDuration: const Duration(milliseconds: 320),
                    reverseTransitionDuration: const Duration(milliseconds: 280),
                    transitionsBuilder: (_, animation, __, child) {
                      final slide = Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ));
                      return SlideTransition(position: slide, child: child);
                    },
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: meta.gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: meta.gradient.first.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background watermark
                      Positioned(
                        right: -16, bottom: -16,
                        child: Icon(meta.icon,
                            size: 72,
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      // Count pill — absolute top-right
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('$count prompts',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(meta.emoji,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 3),
                            Text(meta.label,
                                style: GoogleFonts.sora(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Flexible(
                              child: Text(meta.description,
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.white.withValues(alpha: 0.75)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Featured section
          if (!provider.isLoading && provider.prompts.isNotEmpty) ...[
            Text('Featured Prompts',
                style: GoogleFonts.sora(
                    fontSize: 20, fontWeight: FontWeight.w700, color: colors.onSurface)),
            const SizedBox(height: 4),
            Text('Handpicked across all categories',
                style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
            Builder(builder: (_) {
              final featured = provider.prompts.take(isDesktop ? 6 : 4).toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featured.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 245,
                ),
                itemBuilder: (_, i) => PromptCard(prompt: featured[i]),
              );
            }),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CategoryMeta {
  final String label;
  final String emoji;
  final String description;
  final List<Color> gradient;
  final IconData icon;

  const _CategoryMeta({
    required this.label,
    required this.emoji,
    required this.description,
    required this.gradient,
    required this.icon,
  });
}

// ── Category Banner ───────────────────────────────────────────

class _CategoryBanner extends StatelessWidget {
  final _CategoryMeta meta;
  final int promptCount;
  final AppColors colors;

  const _CategoryBanner({
    required this.meta,
    required this.promptCount,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.15),
                colors.secondary.withValues(alpha: 0.08),
                colors.primaryContainer.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji in a frosted circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(meta.emoji, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 18),
              // Title + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Prompt count pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$promptCount prompt${promptCount == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Detail Page ──────────────────────────────────────

class _CategoryDetailPage extends StatefulWidget {
  final Category category;
  final _CategoryMeta meta;

  const _CategoryDetailPage({
    required this.category,
    required this.meta,
  });

  @override
  State<_CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<_CategoryDetailPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _sortBy = 'Trending';
  ModelType? _filterModel;

  static const _sortOptions = ['Trending', 'Most Liked', 'Most Viewed'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static double _parseCount(String s) {
    final v = s.trim().toUpperCase();
    if (v.endsWith('K')) return (double.tryParse(v.replaceAll('K', '')) ?? 0) * 1000;
    if (v.endsWith('M')) return (double.tryParse(v.replaceAll('M', '')) ?? 0) * 1000000;
    return double.tryParse(v) ?? 0;
  }

  List<PromptItem> _applyFilters(List<PromptItem> all) {
    var list = all.where((p) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!p.title.toLowerCase().contains(q) &&
            !p.description.toLowerCase().contains(q) &&
            !p.tags.any((t) => t.toLowerCase().contains(q))) { return false; }
      }
      if (_filterModel != null && p.model != _filterModel) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'Most Liked':  list.sort((a, b) => b.likes.compareTo(a.likes)); break;
      case 'Most Viewed': list.sort((a, b) => _parseCount(b.viewsCount).compareTo(_parseCount(a.viewsCount))); break;
      default: break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final hPad = isDesktop ? 32.0 : 16.0;

    final allPrompts = provider.prompts
        .where((p) => p.category == widget.category)
        .toList();
    final filtered = _applyFilters(allPrompts);

    // Unique models in this category
    final models = allPrompts.map((p) => p.model).toSet().toList();

    return PopScope(
      canPop: true,
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
        ),
        title: Row(
          children: [
            Text(widget.meta.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.meta.label,
                style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${filtered.length} prompt${filtered.length == 1 ? '' : 's'}',
              style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Banner ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 22, hPad, 16),
              child: _CategoryBanner(
                meta: widget.meta,
                promptCount: allPrompts.length,
                colors: colors,
              ),
            ),
          ),

          // ── Search + Sort ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: colors.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.meta.label.toLowerCase()} prompts...',
                          hintStyle: TextStyle(
                              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: colors.primary, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded,
                                      size: 16, color: colors.onSurfaceVariant),
                                  onPressed: () => setState(() {
                                    _query = '';
                                    _searchCtrl.clear();
                                  }),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sort dropdown
                  PopupMenuButton<String>(
                    initialValue: _sortBy,
                    onSelected: (v) => setState(() => _sortBy = v),
                    color: colors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => _sortOptions
                        .map((o) => PopupMenuItem(
                              value: o,
                              child: Text(o,
                                  style: TextStyle(
                                      color: _sortBy == o
                                          ? colors.primary
                                          : colors.onSurface,
                                      fontWeight: _sortBy == o
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ))
                        .toList(),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sort_rounded,
                              size: 18, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(_sortBy,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more_rounded,
                              size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Model filter chips ────────────────────────────────
          if (models.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // "All" chip
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _filterModel == null,
                          onSelected: (_) => setState(() => _filterModel = null),
                          selectedColor: colors.primary.withValues(alpha: 0.15),
                          checkmarkColor: colors.primary,
                          labelStyle: TextStyle(
                            color: _filterModel == null
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontWeight: _filterModel == null
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: _filterModel == null
                                ? colors.primary
                                : colors.outline.withValues(alpha: 0.2),
                          ),
                          backgroundColor: colors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      ...models.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(m.displayName),
                          selected: _filterModel == m,
                          onSelected: (_) => setState(() =>
                              _filterModel = _filterModel == m ? null : m),
                          selectedColor: colors.primary.withValues(alpha: 0.15),
                          checkmarkColor: colors.primary,
                          labelStyle: TextStyle(
                            color: _filterModel == m
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontWeight: _filterModel == m
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: _filterModel == m
                                ? colors.primary
                                : colors.outline.withValues(alpha: 0.2),
                          ),
                          backgroundColor: colors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),

          // ── Results ───────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 48, color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No prompts found',
                        style: GoogleFonts.sora(color: colors.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() {
                        _query = '';
                        _searchCtrl.clear();
                        _filterModel = null;
                        _sortBy = 'Trending';
                      }),
                      child: Text('Clear filters',
                          style: TextStyle(color: colors.primary)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PromptCard(
                    prompt: filtered[i],
                    onTap: () {
                      Navigator.pop(context);
                      provider.openPromptDetails(filtered[i]);
                    },
                  ),
                  childCount: filtered.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 245,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
