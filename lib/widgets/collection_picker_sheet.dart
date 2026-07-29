import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../theme/app_theme.dart';

class CollectionPickerSheet extends StatefulWidget {
  final String promptId;
  const CollectionPickerSheet({super.key, required this.promptId});

  static Future<void> show(BuildContext context, String promptId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectionPickerSheet(promptId: promptId),
    );
  }

  @override
  State<CollectionPickerSheet> createState() => _CollectionPickerSheetState();
}

class _CollectionPickerSheetState extends State<CollectionPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final colors = AppColors.of(context);
    final collections = provider.collections;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Save to Collection',
                    style: GoogleFonts.sora(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface)),
                TextButton.icon(
                  onPressed: () => _createNew(context, provider, colors),
                  icon: Icon(Icons.add_rounded, size: 16, color: colors.primary),
                  label: Text('New', style: TextStyle(color: colors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (collections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No collections yet. Create one!',
                  style: GoogleFonts.inter(color: colors.onSurfaceVariant)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collections.length,
              itemBuilder: (_, i) {
                final col = collections[i];
                final isIn = provider.isInCollection(widget.promptId, col.id);
                return ListTile(
                  leading: Text(col.emoji,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(col.name,
                      style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${col.promptIds.length} prompt${col.promptIds.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: colors.onSurfaceVariant, fontSize: 12)),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isIn
                          ? colors.primary
                          : colors.surfaceContainerHigh,
                      border: Border.all(
                        color: isIn
                            ? colors.primary
                            : colors.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: isIn
                        ? Icon(Icons.check_rounded,
                            size: 16, color: colors.onPrimary)
                        : null,
                  ),
                  onTap: () {
                    provider.toggleInCollection(widget.promptId, col.id);
                    setState(() {});
                  },
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _createNew(BuildContext context, MarketplaceProvider provider, AppColors colors) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '📁';
    const emojis = ['📁', '❤️', '⭐', '🎨', '💼', '🎬', '💡', '🔥', '🚀', '🎯'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('New Collection',
              style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700, color: colors.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8, runSpacing: 8,
                children: emojis.map((e) => GestureDetector(
                  onTap: () => setS(() => selectedEmoji = e),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: selectedEmoji == e
                          ? colors.primary.withValues(alpha: 0.15)
                          : colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedEmoji == e
                            ? colors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 18))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: TextStyle(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: colors.onSurfaceVariant),
                  filled: true,
                  fillColor: colors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () { nameCtrl.dispose(); Navigator.pop(ctx); },
                child: Text('Cancel',
                    style: TextStyle(color: colors.onSurfaceVariant))),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                provider.createCollection(name, selectedEmoji);
                nameCtrl.dispose();
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
