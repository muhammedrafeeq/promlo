import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import 'prompt_form_dialog.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  List<Map<String, dynamic>> _prompts = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await SupabaseService.fetchPrompts();
      if (mounted) setState(() { _prompts = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(title: 'Delete "$title"?'),
    );
    if (confirmed != true) return;
    try {
      await SupabaseService.deletePrompt(id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _openForm({Map<String, dynamic>? prompt}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PromptFormDialog(existing: prompt),
    );
    if (saved == true && mounted) _load();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _prompts;
    final q = _search.toLowerCase();
    return _prompts.where((p) {
      return (p['title'] ?? '').toLowerCase().contains(q) ||
          (p['category'] ?? '').toLowerCase().contains(q) ||
          (p['model'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(child: Text('Admin is only available on web.')),
      );
    }
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainer,
        elevation: 0,
        title: Text(
          'Promlo — Admin',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.primary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, size: 18, color: colors.onSurfaceVariant),
            label: Text('Refresh', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Prompt'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: colors.surfaceContainer,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by title, category or model…',
                hintStyle: TextStyle(color: colors.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
                filled: true,
                fillColor: colors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Body
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.tertiary),
            const SizedBox(height: 12),
            Text('Failed to load prompts', style: GoogleFonts.sora(color: colors.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_error!, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'No prompts yet. Click "Add Prompt" to create one.' : 'No results for "$_search".',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 900;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: wide ? _buildTable(items, colors) : _buildCards(items, colors),
      );
    });
  }

  // ── Desktop: data table ──────────────────────────────────────

  Widget _buildTable(List<Map<String, dynamic>> items, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardGlassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(colors.surfaceContainerHigh),
        headingTextStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: colors.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
        dataTextStyle: TextStyle(color: colors.onSurface, fontSize: 13),
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('TITLE')),
          DataColumn(label: Text('CATEGORY')),
          DataColumn(label: Text('MODEL')),
          DataColumn(label: Text('LIKES')),
          DataColumn(label: Text('TRENDING')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: items.map((p) => DataRow(cells: [
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(p['title'] ?? '—', overflow: TextOverflow.ellipsis),
            ),
          ),
          DataCell(_CategoryChip(p['category'] ?? '—', colors)),
          DataCell(Text(p['model'] ?? '—')),
          DataCell(Text('${p['likes'] ?? 0}')),
          DataCell(Icon(
            (p['is_trending_now'] == true) ? Icons.trending_up_rounded : Icons.remove_rounded,
            size: 16,
            color: (p['is_trending_now'] == true) ? colors.secondary : colors.onSurfaceVariant,
          )),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                tooltip: 'Edit',
                onPressed: () => _openForm(prompt: p),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.tertiary),
                tooltip: 'Delete',
                onPressed: () => _delete(p['id'], p['title'] ?? ''),
              ),
            ],
          )),
        ])).toList(),
      ),
    );
  }

  // ── Mobile: cards ─────────────────────────────────────────────

  Widget _buildCards(List<Map<String, dynamic>> items, AppColors colors) {
    return Column(
      children: items.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.cardGlassBorder),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(p['title'] ?? '—', style: GoogleFonts.sora(fontWeight: FontWeight.w600, color: colors.onSurface)),
          subtitle: Text('${p['category']} · ${p['model']}', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: Icon(Icons.edit_outlined, color: colors.primary), onPressed: () => _openForm(prompt: p)),
              IconButton(icon: Icon(Icons.delete_outline_rounded, color: colors.tertiary), onPressed: () => _delete(p['id'], p['title'] ?? '')),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _CategoryChip(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.w600)),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  const _ConfirmDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Delete', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
      content: Text(title),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
