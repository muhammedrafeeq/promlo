import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prompt_model.dart';
import '../providers/marketplace_provider.dart';

class CreatePromptDialog extends StatefulWidget {
  const CreatePromptDialog({super.key});

  @override
  State<CreatePromptDialog> createState() => _CreatePromptDialogState();
}

class _CreatePromptDialogState extends State<CreatePromptDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _promptController = TextEditingController();
  final _tagsController = TextEditingController();
  Category _selectedCategory = Category.image;
  ModelType _selectedModel = ModelType.gpt4;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _promptController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty ||
        _promptController.text.trim().isEmpty) {
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final newPrompt = PromptItem(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : _promptController.text.trim().substring(
                0,
                _promptController.text.trim().length > 60
                    ? 60
                    : _promptController.text.trim().length,
              ),
      fullPrompt: _promptController.text.trim(),
      category: _selectedCategory,
      model: _selectedModel,
      likes: 1,
      tags: tags.isNotEmpty ? tags : [_selectedCategory.displayName],
      creator: const Creator(
        name: 'Alex Rivera (You)',
        avatar:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB09b-1tApErz5rBokrhHCFIFLrcSKwM00tF5nH0a4lvxyu_Vn2WoMHyG7M7al_Zk7pJqpKX5NE6lHkOiCsZncinQxrFHVjpD9uyH2388MwBRpv-eyPOwUYmYWPm24luKsjy4_agDG4qz-Rl43KW3o3ZDld1Oh5guw_HAGcmt8ZD4oxtuIJM55qvOWP-_jlAdDpK5eUi_q24Q5oKowCms8217exGLv1t9qrZvnIFX5FFubcffUSspHIEc113r9Rz1rGuyFEy8Tafvek',
        role: 'Prompt Engineer',
      ),
      bentoSpan: BentoSpan.medium,
    );

    final messenger = ScaffoldMessenger.of(context);
    Provider.of<MarketplaceProvider>(context, listen: false)
        .addPrompt(newPrompt);
    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        content: Text('Published "${newPrompt.title}" to Promlo!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forge New Prompt',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Prompt Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: Category.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ModelType>(
                      initialValue: _selectedModel,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                      items: ModelType.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m.displayName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedModel = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Full Prompt Template *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Publish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
