import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';
import 'collection_picker_sheet.dart';

class SkeletonPromptCard extends StatefulWidget {
  const SkeletonPromptCard({super.key});

  @override
  State<SkeletonPromptCard> createState() => _SkeletonPromptCardState();
}

class _SkeletonPromptCardState extends State<SkeletonPromptCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerValue = _controller.value;
        final shimmerGradient = LinearGradient(
          begin: Alignment(-1.5 + shimmerValue * 3, 0),
          end: Alignment(-0.5 + shimmerValue * 3, 0),
          colors: [
            colors.surfaceContainerLow,
            colors.surfaceContainerLow.withValues(alpha: 0.5),
            colors.surfaceContainer,
            colors.surfaceContainerLow.withValues(alpha: 0.5),
            colors.surfaceContainerLow,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        );

        return Container(
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardGlassBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail placeholder
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(gradient: shimmerGradient),
                child: Stack(
                  children: [
                    // Badge placeholders
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          _ShimmerBox(width: 60, height: 20, gradient: shimmerGradient, radius: 6),
                          const SizedBox(width: 8),
                          _ShimmerBox(width: 48, height: 20, gradient: shimmerGradient, radius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content body placeholder
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    _ShimmerBox(width: double.infinity, height: 16, gradient: shimmerGradient, radius: 4),
                    const SizedBox(height: 12),

                    // Author + stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _ShimmerBox(width: 22, height: 22, gradient: shimmerGradient, radius: 11),
                            const SizedBox(width: 6),
                            _ShimmerBox(width: 80, height: 13, gradient: shimmerGradient, radius: 4),
                          ],
                        ),
                        Row(
                          children: [
                            _ShimmerBox(width: 36, height: 13, gradient: shimmerGradient, radius: 4),
                            const SizedBox(width: 12),
                            _ShimmerBox(width: 36, height: 13, gradient: shimmerGradient, radius: 4),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final LinearGradient gradient;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.gradient,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class PromptCard extends StatelessWidget {
  final PromptItem prompt;
  final VoidCallback? onTap;

  const PromptCard({super.key, required this.prompt, this.onTap});

  Color _getCategoryBadgeBg(AppColors colors, Category category, String tag) {
    if (tag.toLowerCase() == 'interactive' || category == Category.writing) {
      return colors.tertiaryContainer.withValues(alpha: 0.9);
    }
    return colors.secondaryContainer.withValues(alpha: 0.9);
  }

  Color _getCategoryBadgeText(AppColors colors, Category category, String tag) {
    if (tag.toLowerCase() == 'interactive' || category == Category.writing) {
      return colors.onTertiaryContainer;
    }
    return colors.onSecondaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = Provider.of<MarketplaceProvider>(context);
    final isSaved = provider.savedIds.contains(prompt.id);

    final tagText = prompt.tags.isNotEmpty
        ? prompt.tags.first
        : prompt.category.displayName;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardGlassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.cardGlassBorder,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => provider.openPromptDetails(prompt),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. THUMBNAIL WITH DUAL BADGES OVERLAY
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: prompt.imageUrl ??
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.surfaceContainerLow,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colors.surfaceContainerLow,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          colors.background.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top-Left Dual Badges (Category Pill + Model Pill)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      // Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryBadgeBg(colors, prompt.category, tagText),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tagText.toUpperCase(),
                          style: TextStyle(
                            color: _getCategoryBadgeText(colors, prompt.category, tagText),
                            fontSize: AppSizes.of(context).caption,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Model Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          prompt.model.displayName.toUpperCase(),
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: AppSizes.of(context).caption,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

            // 2. CARD CONTENT BODY
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    prompt.title,
                    style: GoogleFonts.sora(
                      fontSize: AppSizes.of(context).isSmall ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Bottom Row: Author Section (Ahead) + Likes & Views Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Author Profile (Avatar + Creator Name)
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.network(
                                prompt.creator.avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: colors.primaryContainer,
                                  child: const Icon(Icons.person, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppSizes.of(context).isSmall ? 80 : 110,
                            ),
                            child: Text(
                              prompt.creator.name,
                              style: TextStyle(
                                fontSize: AppSizes.of(context).body,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Likes & Views Stats
                      Row(
                        children: [
                          // Likes / Save
                          InkWell(
                            onTap: () => CollectionPickerSheet.show(context, prompt.id),
                            child: Row(
                              children: [
                                Icon(
                                  isSaved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isSaved
                                      ? colors.tertiary
                                      : colors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  prompt.likesFormatted ?? '${prompt.likes}',
                                  style: TextStyle(
                                    fontSize: AppSizes.of(context).body,
                                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Views
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 16,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                prompt.viewsCount,
                                style: TextStyle(
                                  fontSize: AppSizes.of(context).body,
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
