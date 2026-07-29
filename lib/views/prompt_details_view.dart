import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';

class PromptDetailsView extends StatefulWidget {
  final PromptItem prompt;
  final VoidCallback onBack;

  const PromptDetailsView({
    super.key,
    required this.prompt,
    required this.onBack,
  });

  @override
  State<PromptDetailsView> createState() => _PromptDetailsViewState();
}

class _PromptDetailsViewState extends State<PromptDetailsView> {
  bool _isCopied = false;
  bool _liked = false;
  int _localLikes = 0;
  int _localViews = 0;
  int _localBookmarks = 0;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
    _subscribeRealtime();
  }

  Future<void> _fetchCounts() async {
    try {
      final row = await Supabase.instance.client
          .from('prompts')
          .select('likes, views_count, bookmarks_count')
          .eq('id', widget.prompt.id)
          .single();
      if (!mounted) return;
      final views = _parseCount((row['views_count'] ?? '0').toString());
      final likes = (row['likes'] as num?)?.toInt() ?? 0;
      setState(() {
        _localLikes = likes;
        _localViews = views;
        _localBookmarks = (row['bookmarks_count'] as num?)?.toInt() ?? 0;
      });
      // increment view count
      final newViews = views + 1;
      await Supabase.instance.client
          .from('prompts')
          .update({'views_count': '$newViews'})
          .eq('id', widget.prompt.id);
      if (mounted) {
        setState(() => _localViews = newViews);
        // sync provider list so cards reflect updated view count
        Provider.of<MarketplaceProvider>(context, listen: false)
            .updatePromptCounts(widget.prompt.id, viewsCount: '$newViews');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  int _parseCount(String s) {
    final clean = s.toLowerCase().replaceAll(',', '').trim();
    if (clean.endsWith('k')) return ((double.tryParse(clean.replaceAll('k', '')) ?? 0) * 1000).toInt();
    if (clean.endsWith('m')) return ((double.tryParse(clean.replaceAll('m', '')) ?? 0) * 1000000).toInt();
    return int.tryParse(clean) ?? 0;
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  void _subscribeRealtime() {
    _realtimeChannel = Supabase.instance.client
        .channel('prompt_detail_${widget.prompt.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'prompts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.prompt.id,
          ),
          callback: (payload) {
            if (!mounted) return;
            final r = payload.newRecord;
            final newLikes = (r['likes'] as num?)?.toInt() ?? _localLikes;
            final newViewsStr = (r['views_count'] ?? '').toString();
            final newViews = newViewsStr.isNotEmpty ? _parseCount(newViewsStr) : _localViews;
            final newBookmarks = (r['bookmarks_count'] as num?)?.toInt() ?? _localBookmarks;
            setState(() {
              _localLikes = newLikes;
              _localViews = newViews;
              _localBookmarks = newBookmarks;
            });
            Provider.of<MarketplaceProvider>(context, listen: false)
                .updatePromptCounts(widget.prompt.id, likes: newLikes, viewsCount: newViewsStr);
          },
        )
        .subscribe((status, [error]) {
          if (error != null && mounted) {
            debugPrint('Realtime subscription error: $error');
          }
        });
  }

  Future<void> _toggleLike() async {
    final wasLiked = _liked;
    final newLikes = wasLiked ? _localLikes - 1 : _localLikes + 1;
    setState(() {
      _liked = !wasLiked;
      _localLikes = newLikes;
    });
    try {
      await Supabase.instance.client
          .from('prompts')
          .update({'likes': newLikes})
          .eq('id', widget.prompt.id);
      if (mounted) {
        Provider.of<MarketplaceProvider>(context, listen: false)
            .updatePromptCounts(widget.prompt.id, likes: newLikes);
      }
    } catch (_) {
      if (mounted) setState(() { _liked = wasLiked; _localLikes = newLikes + (wasLiked ? 1 : -1); });
    }
  }

  void _showBookmarkSheet(BuildContext context, MarketplaceProvider provider) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Save to Collection',
                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: colors.onSurface)),
                  const SizedBox(height: 16),
                  ...provider.collections.map((c) {
                    final inCollection = provider.isInCollection(widget.prompt.id, c.id);
                    return ListTile(
                      leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(c.name, style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600)),
                      trailing: Icon(
                        inCollection ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: inCollection ? colors.primary : colors.onSurfaceVariant,
                      ),
                      onTap: () {
                        provider.toggleInCollection(widget.prompt.id, c.id);
                        setS(() {});
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _copyPromptToClipboard() {
    final colors = AppColors.of(context);
    Clipboard.setData(ClipboardData(text: widget.prompt.fullPrompt));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'Prompt copied to clipboard!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: colors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = Provider.of<MarketplaceProvider>(context);
    final isBookmarked = provider.savedIds.contains(widget.prompt.id);
    final isSaved = isBookmarked;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    colors.secondary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // TOP APP BAR
              Builder(builder: (context) {
                final statusBar = MediaQuery.of(context).padding.top;
                return Container(
                  height: 56 + statusBar,
                  color: colors.surfaceContainerLow,
                  padding: EdgeInsets.only(top: statusBar),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
                        onPressed: widget.onBack,
                        tooltip: 'Back',
                      ),
                      Expanded(
                        child: Text(
                          widget.prompt.title,
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isBookmarked ? colors.primary : colors.onSurfaceVariant,
                        ),
                        onPressed: () => _showBookmarkSheet(context, provider),
                        tooltip: 'Save to collection',
                      ),
                    ],
                  ),
                );
              }),

              // 2. SCROLLABLE BODY CONTENT
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 12,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        children: [
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _buildLeftColumn(context, provider, isSaved),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 5,
                                  child: _buildRightColumn(context, provider),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildLeftColumn(context, provider, isSaved),
                                const SizedBox(height: 24),
                                _buildRightColumn(context, provider),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LEFT COLUMN BUILDER
  Widget _buildLeftColumn(
      BuildContext context, MarketplaceProvider provider, bool isSaved) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Preview Container matching HTML
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: widget.prompt.imageUrl ??
                      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: colors.surfaceContainerLow,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: colors.surfaceContainerLow,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 14, color: colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _formatCount(_localViews),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Creator Card Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        widget.prompt.creator.avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colors.primaryContainer,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.prompt.creator.name,
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pro Member • Verified Creator',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Title, Tags & Description
        Text(
          widget.prompt.title,
          style: GoogleFonts.sora(
            fontSize: MediaQuery.of(context).size.width >= 1024 ? 28 : AppSizes.of(context).h1,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.secondaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.prompt.model.displayName,
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.tertiaryContainer.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.prompt.category.displayName,
                style: TextStyle(
                  color: colors.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.prompt.tags.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.prompt.tags.first,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        Text(
          widget.prompt.description,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: colors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        // Analytics Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tappable like button
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(_liked),
                        color: _liked ? Colors.redAccent : colors.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatCount(_localLikes),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _liked ? Colors.redAccent : colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.visibility_rounded, color: colors.secondary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _formatCount(_localViews),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.bookmark_rounded,
                      color: isSaved ? colors.primary : colors.onSurfaceVariant,
                      size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _formatCount(_localBookmarks),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // RIGHT COLUMN BUILDER
  Widget _buildRightColumn(BuildContext context, MarketplaceProvider provider) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. THE PROMPT BLOCK (WITH TOP RAINBOW GRADIENT BAR)
        Container(
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rainbow Gradient Accent Line
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: "The Prompt" + "Copy"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.terminal_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'The Prompt',
                              style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _copyPromptToClipboard,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colors.surfaceContainerLow,
                            side: BorderSide(
                              color: colors.outline.withValues(alpha: 0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: Icon(
                            _isCopied
                                ? Icons.check_rounded
                                : Icons.content_copy_rounded,
                            size: 14,
                            color: colors.primary,
                          ),
                          label: Text(
                            _isCopied ? 'Copied' : 'Copy',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Monospaced Code Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.surfaceContainerLow,
                        ),
                      ),
                      child: Text(
                        widget.prompt.fullPrompt,
                        style: GoogleFonts.firaCode(
                          fontSize: 13,
                          color: colors.primary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Callout Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.primaryContainer.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: colors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This prompt is optimised for ${widget.prompt.model.displayName}. Copy and paste it directly into your preferred AI tool.',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. HOW TO USE SECTION (NUMBERED STEPS 1-4)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: colors.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How to Use',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildStepRow(context, '1', 'Copy the code',
                  'Click the copy button above to get the full raw prompt string.'),
              const SizedBox(height: 16),
              _buildStepRow(context, '2', 'Navigate to Discord',
                  'Open your Midjourney bot channel or direct message thread.'),
              const SizedBox(height: 16),
              _buildStepRow(context, '3', 'Paste and Run',
                  'Paste the prompt into the message box and hit enter to generate.'),
              const SizedBox(height: 16),
              _buildStepRow(context, '4', 'Refine Results',
                  'Use the variation buttons (V1-V4) to fine-tune the output.'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. YOU MIGHT ALSO LIKE (SUGGESTIONS CAROUSEL)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOU MIGHT ALSO LIKE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.prompts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = provider.prompts[index];
                    return InkWell(
                      onTap: () => provider.openPromptDetails(item),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surfaceContainerLow),
                          errorWidget: (_, __, ___) =>
                              Container(color: colors.surfaceContainerLow),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(BuildContext context, String stepNumber, String title, String subtitle) {
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
