import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/prompt_card.dart';
import '../theme/app_theme.dart';

class SavedView extends StatefulWidget {
  const SavedView({super.key});

  @override
  State<SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<SavedView> {
  bool _bulkMode = false;
  final Set<String> _selected = {};

  void _toggleBulkMode() {
    setState(() {
      _bulkMode = !_bulkMode;
      _selected.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _deleteSelected(MarketplaceProvider provider) {
    final colors = AppColors.of(context);
    final count = _selected.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.tertiary.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Remove $count Prompt${count == 1 ? '' : 's'}?',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        content: Text(
          'This will remove the selected prompt${count == 1 ? '' : 's'} from your saved collection.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: colors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              for (final id in _selected) {
                provider.toggleSave(id);
              }
              setState(() { _selected.clear(); _bulkMode = false; });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: colors.tertiary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Removed $count prompt${count == 1 ? '' : 's'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  backgroundColor: colors.surfaceContainerHigh,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Remove', style: GoogleFonts.inter(color: colors.tertiary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _clearAll(MarketplaceProvider provider) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.tertiary.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Clear All Saved?',
          style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface),
        ),
        content: Text(
          'This will remove all saved prompts from your collection.',
          style: GoogleFonts.inter(
              fontSize: 14, color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: colors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllSaved();
              Navigator.pop(ctx);
              setState(() {
                _bulkMode = false;
                _selected.clear();
              });
            },
            child: Text('Clear All',
                style: GoogleFonts.inter(
                    color: colors.tertiary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final provider = Provider.of<MarketplaceProvider>(context);
    final savedPrompts = provider.prompts
        .where((p) => provider.savedIds.contains(p.id))
        .toList();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet =
        MediaQuery.of(context).size.width >= 640 && !isDesktop;
    final crossCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.tertiaryContainer.withValues(alpha: 0.15),
                  border: Border.all(
                      color: colors.tertiary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.tertiary.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(Icons.bookmark_rounded,
                    color: colors.tertiary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Saved Prompts',
                          style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: colors.tertiary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${savedPrompts.length}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colors.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Your private vault of bookmarked prompts.',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (savedPrompts.isNotEmpty)
                Row(
                  children: [
                    if (_bulkMode) ...[
                      if (_selected.isNotEmpty)
                        _HeaderAction(
                          icon: Icons.delete_rounded,
                          label: 'Remove (${_selected.length})',
                          color: colors.tertiary,
                          onTap: () => _deleteSelected(provider),
                        ),
                      const SizedBox(width: 8),
                    ],
                    _HeaderAction(
                      icon: _bulkMode ? Icons.close_rounded : Icons.checklist_rounded,
                      label: _bulkMode ? 'Done' : 'Select',
                      color: colors.primary,
                      onTap: _toggleBulkMode,
                    ),
                    const SizedBox(width: 8),
                    _HeaderAction(
                      icon: Icons.delete_sweep_rounded,
                      label: 'Clear All',
                      color: colors.tertiary,
                      onTap: () => _clearAll(provider),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 28),

          // Empty state
          if (savedPrompts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 48),
                  decoration: BoxDecoration(
                    color: colors.cardGlassBg,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: colors.cardGlassBorder, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.tertiaryContainer
                              .withValues(alpha: 0.1),
                          border: Border.all(
                              color: colors.tertiary.withValues(alpha: 0.25),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: colors.tertiary.withValues(alpha: 0.12),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(Icons.bookmark_border_rounded,
                            size: 36, color: colors.tertiary),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nothing Saved Yet',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any prompt card to add it to your personal collection.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () =>
                            provider.setActiveTab(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colors.tertiary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.explore_rounded,
                                  size: 15, color: colors.tertiary),
                              const SizedBox(width: 8),
                              Text(
                                'Browse Trending',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.tertiary,
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedPrompts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 245,
              ),
              itemBuilder: (_, i) {
                final prompt = savedPrompts[i];
                if (_bulkMode) {
                  final selected = _selected.contains(prompt.id);
                  return GestureDetector(
                    onTap: () => _toggleSelect(prompt.id),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? colors.tertiary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: IgnorePointer(
                            child: PromptCard(prompt: prompt),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? colors.tertiary
                                  : colors.surfaceContainerHigh
                                      .withValues(alpha: 0.9),
                              border: Border.all(
                                color: selected
                                    ? colors.tertiary
                                    : colors.outline.withValues(alpha: 0.4),
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return PromptCard(prompt: prompt);
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
