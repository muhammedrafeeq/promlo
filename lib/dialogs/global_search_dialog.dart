import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MarketplaceProvider>(context);

    final results = _query.trim().isEmpty
        ? provider.prompts.take(4).toList()
        : provider.prompts.where((p) {
            final q = _query.toLowerCase();
            return p.title.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.tags.any((t) => t.toLowerCase().contains(q));
          }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search prompts, tags, or models...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 16),
            Text(
              _query.isEmpty ? 'Popular Prompts' : 'Results (${results.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final prompt = results[index];
                  return ListTile(
                    title: Text(prompt.title),
                    subtitle: Text(prompt.description,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Chip(label: Text(prompt.model.displayName)),
                    onTap: () {
                      Navigator.of(context).pop();
                      provider.openPromptDetails(prompt);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
