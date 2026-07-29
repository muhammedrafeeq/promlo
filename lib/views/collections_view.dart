import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/collection_model.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/prompt_card.dart';
import 'prompt_details_view.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collections',
                      style: GoogleFonts.sora(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface)),
                  Text('Organise your favourite prompts',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: colors.onSurfaceVariant)),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context, provider, colors),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (provider.collections.isEmpty)
            _emptyState(colors, context, provider)
          else
            _grid(provider, colors, context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _grid(MarketplaceProvider provider, AppColors colors, BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final cols = isDesktop ? 3 : (isTablet ? 2 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.collections.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 160,
      ),
      itemBuilder: (_, i) {
        final col = provider.collections[i];
        final promptCount = col.promptIds.length;
        final preview = provider.prompts
            .where((p) => col.promptIds.contains(p.id))
            .take(3)
            .toList();

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => _CollectionDetailPage(collection: col),
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
              color: colors.cardGlassBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardGlassBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Preview thumbnail strip
                if (preview.isNotEmpty)
                  Positioned.fill(
                    child: Row(
                      children: preview.map((p) => Expanded(
                        child: p.imageUrl != null
                            ? Image.network(p.imageUrl!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: colors.surfaceContainerLow))
                            : Container(color: colors.surfaceContainerLow),
                      )).toList(),
                    ),
                  ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.background.withValues(alpha: 0.3),
                          colors.background.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 16, right: 16, bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(col.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(col.name,
                          style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('$promptCount prompt${promptCount == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                // 3-dot menu
                Positioned(
                  top: 8, right: 8,
                  child: _CollectionMenuButton(
                    col: col,
                    colors: colors,
                    onEdit: () => _showCreateDialog(context, provider, colors, editing: col),
                    onDelete: col.id != 'default'
                        ? () => provider.deleteCollection(col.id)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(AppColors colors, BuildContext context, MarketplaceProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: colors.cardGlassBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.cardGlassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📁', style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text('No Collections Yet',
                  style: GoogleFonts.sora(
                      fontSize: 18, fontWeight: FontWeight.w700, color: colors.onSurface)),
              const SizedBox(height: 8),
              Text('Create collections to organise your prompts by theme or project.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context, provider, colors),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create Collection'),
                style: FilledButton.styleFrom(
                    backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, MarketplaceProvider provider, AppColors colors,
      {Collection? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    String selectedEmoji = editing?.emoji ?? '📁';
    const emojis = ['📁', '❤️', '⭐', '🎨', '💼', '🎬', '💡', '🔥', '🚀', '🎯', '🌟', '🧠'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    editing == null ? 'New Collection' : 'Edit Collection',
                    style: GoogleFonts.sora(
                        fontSize: 18, fontWeight: FontWeight.w700, color: colors.onSurface),
                  ),
                  const SizedBox(height: 20),

                  // Emoji picker
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: emojis.map((e) => GestureDetector(
                      onTap: () => setS(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: selectedEmoji == e
                              ? colors.primary.withValues(alpha: 0.15)
                              : colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedEmoji == e ? colors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: TextStyle(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Collection name',
                      hintStyle: TextStyle(color: colors.onSurfaceVariant),
                      filled: true,
                      fillColor: colors.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () { nameCtrl.dispose(); Navigator.pop(ctx); },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onSurfaceVariant,
                            side: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            final isDuplicate = provider.collections.any((c) =>
                                c.name.toLowerCase() == name.toLowerCase() &&
                                (editing == null || c.id != editing.id));
                            if (isDuplicate) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('A collection named "$name" already exists.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                              );
                              return;
                            }
                            if (editing == null) {
                              provider.createCollection(name, selectedEmoji);
                            } else {
                              provider.renameCollection(editing.id, name, selectedEmoji);
                            }
                            nameCtrl.dispose();
                            Navigator.pop(ctx);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(editing == null ? 'Create' : 'Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class _CollectionMenuButton extends StatelessWidget {
  final Collection col;
  final AppColors colors;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CollectionMenuButton({
    required this.col,
    required this.colors,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete?.call();
      },
      color: colors.surfaceContainerHigh,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 36),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: colors.primary),
              const SizedBox(width: 10),
              Text('Edit', style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 18, color: colors.tertiary),
                const SizedBox(width: 10),
                Text('Delete', style: TextStyle(color: colors.tertiary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert_rounded, size: 16, color: colors.onSurfaceVariant),
      ),
    );
  }
}

// ── Collection Detail Page ────────────────────────────────────

class _CollectionDetailPage extends StatelessWidget {
  final Collection collection;

  const _CollectionDetailPage({required this.collection});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final prompts = provider.prompts
        .where((p) => collection.promptIds.contains(p.id))
        .toList();

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
            Text(collection.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                collection.name,
                style: GoogleFonts.sora(
                    fontSize: 18, fontWeight: FontWeight.w700, color: colors.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${prompts.length} prompt${prompts.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      body: prompts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 52, color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('This collection is empty',
                      style: GoogleFonts.sora(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('Tap ♡ on any prompt card to add it here.',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6))),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: 20,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: prompts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 245,
              ),
              itemBuilder: (_, i) => PromptCard(
                prompt: prompts[i],
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => PromptDetailsView(
                      prompt: prompts[i],
                      onBack: () => Navigator.pop(context),
                    ),
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
              ),
            ),
      ),
    );
  }
}
