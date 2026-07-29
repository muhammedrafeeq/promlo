import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';

class PromptDetailDialog extends StatefulWidget {
  final PromptItem prompt;

  const PromptDetailDialog({super.key, required this.prompt});

  @override
  State<PromptDetailDialog> createState() => _PromptDetailDialogState();
}

class _PromptDetailDialogState extends State<PromptDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);
    final isSaved = provider.savedIds.contains(widget.prompt.id);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(widget.prompt.model.displayName),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(widget.prompt.category.displayName),
                            labelStyle: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        widget.prompt.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded),
                  color: isSaved
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  onPressed: () => provider.toggleSave(widget.prompt.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Prompt Template'),
                Tab(text: 'Parameters & Config'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Prompt Text
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.prompt.description,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            widget.prompt.fullPrompt,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Parameters
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Temperature'),
                          subtitle: Text(
                              '${widget.prompt.parameters.temperature}'),
                          leading: const Icon(Icons.thermostat_rounded),
                        ),
                        ListTile(
                          title: const Text('Top P'),
                          subtitle:
                              Text('${widget.prompt.parameters.topP}'),
                          leading: const Icon(Icons.tune_rounded),
                        ),
                        if (widget.prompt.parameters.systemPrompt != null)
                          ListTile(
                            title: const Text('System Prompt'),
                            subtitle:
                                Text(widget.prompt.parameters.systemPrompt!),
                            leading: const Icon(Icons.psychology_rounded),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.content_copy_rounded, size: 18),
                  label: const Text('Copy Prompt'),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.prompt.fullPrompt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Prompt copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
