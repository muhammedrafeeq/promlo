import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class PromptFormDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const PromptFormDialog({super.key, this.existing});

  @override
  State<PromptFormDialog> createState() => _PromptFormDialogState();
}

class _PromptFormDialogState extends State<PromptFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _id;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _fullPrompt;
  late final TextEditingController _imageUrl;
  late final TextEditingController _likes;
  late final TextEditingController _viewsCount;
  late final TextEditingController _runsCount;
  late final TextEditingController _price;
  late final TextEditingController _tags;
  late final TextEditingController _creatorName;
  late final TextEditingController _creatorAvatar;
  String _category = 'image';
  String _model = 'gpt4';
  bool _isTrendingNow = false;
  bool _isFeatured = false;

  bool get _isEdit => widget.existing != null;

  static const _categories = ['all', 'video', 'image', 'web', 'code', 'writing'];
  static const _models = ['gpt4', 'geminiPro', 'nano', 'claude35', 'midjourneyV6', 'flux1Pro'];

  @override
  void initState() {
    super.initState();
    final p = widget.existing ?? {};
    _id            = TextEditingController(text: p['id'] ?? '');
    _title         = TextEditingController(text: p['title'] ?? '');
    _description   = TextEditingController(text: p['description'] ?? '');
    _fullPrompt    = TextEditingController(text: p['full_prompt'] ?? '');
    _imageUrl      = TextEditingController(text: p['image_url'] ?? '');
    _likes         = TextEditingController(text: '${p['likes'] ?? 0}');
    _viewsCount    = TextEditingController(text: p['views_count'] ?? '0');
    _runsCount     = TextEditingController(text: p['runs_count'] ?? '0');
    _price         = TextEditingController(text: p['price'] ?? '');
    _creatorName   = TextEditingController(text: p['creator_name'] ?? '');
    _creatorAvatar = TextEditingController(text: p['creator_avatar'] ?? '');
    _tags = TextEditingController(
      text: (p['tags'] is List) ? (p['tags'] as List).join(', ') : (p['tags'] ?? ''),
    );
    _category      = p['category'] ?? 'image';
    _model         = p['model'] ?? 'gpt4';
    _isTrendingNow = p['is_trending_now'] ?? false;
    _isFeatured    = p['is_featured'] ?? false;
  }

  @override
  void dispose() {
    for (final c in [_id, _title, _description, _fullPrompt, _imageUrl, _likes, _viewsCount, _runsCount, _price, _tags, _creatorName, _creatorAvatar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    final tagList = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final payload = {
      'id': _id.text.trim(),
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'full_prompt': _fullPrompt.text.trim(),
      'image_url': _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      'likes': int.tryParse(_likes.text.trim()) ?? 0,
      'views_count': _viewsCount.text.trim(),
      'runs_count': _runsCount.text.trim(),
      'price': _price.text.trim().isEmpty ? null : _price.text.trim(),
      'category': _category,
      'model': _model,
      'tags': tagList,
      'is_trending_now': _isTrendingNow,
      'is_featured': _isFeatured,
      'creator_name': _creatorName.text.trim(),
      'creator_avatar': _creatorAvatar.text.trim(),
    };

    try {
      if (_isEdit) {
        await SupabaseService.updatePrompt(payload['id'] as String, payload);
      } else {
        await SupabaseService.createPrompt(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Dialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          minWidth: 0,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.cardGlassBorder)),
              ),
              child: Row(
                children: [
                  Text(
                    _isEdit ? 'Edit Prompt' : 'New Prompt',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: colors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('Identity', colors),
                      _row([
                        _field(_id, 'ID (slug)', colors, enabled: !_isEdit,
                          hint: 'my-cool-prompt',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(v.trim())) {
                              return 'Lowercase letters, numbers and hyphens only';
                            }
                            return null;
                          }),
                        _field(_title, 'Title', colors,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      ]),
                      _field(_description, 'Short Description', colors, maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      _field(_fullPrompt, 'Full Prompt Text', colors, maxLines: 5,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),

                      const SizedBox(height: 20),
                      _section('Classification', colors),
                      _row([
                        _dropdown('Category', _category, _categories, colors, (v) => setState(() => _category = v!)),
                        _dropdown('Model', _model, _models, colors, (v) => setState(() => _model = v!)),
                      ]),
                      _field(_tags, 'Tags (comma-separated)', colors, hint: 'cinematic, sci-fi, portrait'),

                      const SizedBox(height: 20),
                      _section('Stats & Media', colors),
                      _row([
                        _field(_likes, 'Likes', colors, keyboard: TextInputType.number),
                        _field(_viewsCount, 'Views', colors, hint: '12.4k'),
                        _field(_runsCount, 'Runs', colors, hint: '3.2k'),
                      ]),
                      _field(_imageUrl, 'Image URL', colors, hint: 'https://…'),
                      _field(_price, 'Price', colors, hint: 'e.g. \$4.99 or leave blank for free'),

                      const SizedBox(height: 20),
                      _section('Creator', colors),
                      _row([
                        _field(_creatorName, 'Creator Name', colors),
                        _field(_creatorAvatar, 'Creator Avatar URL', colors),
                      ]),

                      const SizedBox(height: 20),
                      _section('Flags', colors),
                      Row(
                        children: [
                          _toggle('Trending Now', _isTrendingNow, colors, (v) => setState(() => _isTrendingNow = v)),
                          const SizedBox(width: 24),
                          _toggle('Featured', _isFeatured, colors, (v) => setState(() => _isFeatured = v)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.cardGlassBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: colors.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size(120, 44),
                    ),
                    child: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isEdit ? 'Save Changes' : 'Create Prompt'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _section(String label, AppColors colors) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: colors.primary),
    ),
  );

  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.expand((w) => [Expanded(child: w), const SizedBox(width: 12)]).toList()..removeLast(),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    AppColors colors, {
    int maxLines = 1,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboard,
        validator: validator,
        style: TextStyle(color: colors.onSurface, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 12),
          filled: true,
          fillColor: colors.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.cardGlassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.cardGlassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options, AppColors colors, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        style: TextStyle(color: colors.onSurface, fontSize: 13),
        dropdownColor: colors.surfaceContainerHigh,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          filled: true,
          fillColor: colors.surfaceContainerHigh,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.cardGlassBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.cardGlassBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      ),
    );
  }

  Widget _toggle(String label, bool value, AppColors colors, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged, activeThumbColor: colors.primary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: colors.onSurface, fontSize: 13)),
      ],
    );
  }
}
