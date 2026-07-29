import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import 'prompt_form_dialog.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  // ── PIN gate ─────────────────────────────────────────────────
  bool _pinVerified = false;
  final _pinControllers = List.generate(4, (_) => TextEditingController());
  final _pinFocusNodes  = List.generate(4, (_) => FocusNode());
  bool _pinLoading = false;
  String? _pinError;

  // ── Admin content ─────────────────────────────────────────────
  List<Map<String, dynamic>> _prompts = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _pinControllers) { c.dispose(); }
    for (final f in _pinFocusNodes)  { f.dispose(); }
    super.dispose();
  }

  String get _enteredPin => _pinControllers.map((c) => c.text).join();

  void _onPinDigit(int index, String value) {
    if (value.length > 1) _pinControllers[index].text = value[value.length - 1];
    if (value.isNotEmpty && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    }
    if (_enteredPin.length == 4) _verifyPin();
  }

  void _onPinBackspace(int index) {
    if (_pinControllers[index].text.isEmpty && index > 0) {
      _pinControllers[index - 1].clear();
      _pinFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyPin() async {
    if (_pinLoading) return;
    setState(() { _pinLoading = true; _pinError = null; });
    try {
      final row = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', 'admin_pin')
          .single();
      if (!mounted) return;
      if (_enteredPin == (row['value']?.toString() ?? '')) {
        setState(() { _pinVerified = true; });
        _load();
      } else {
        for (final c in _pinControllers) { c.clear(); }
        _pinFocusNodes[0].requestFocus();
        setState(() { _pinLoading = false; _pinError = 'Incorrect PIN. Try again.'; });
      }
    } catch (_) {
      if (mounted) {
        for (final c in _pinControllers) { c.clear(); }
        _pinFocusNodes[0].requestFocus();
        setState(() { _pinLoading = false; _pinError = 'Could not verify PIN. Check connection.'; });
      }
    }
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

    if (!_pinVerified) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surfaceContainer,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Admin Access',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 18, color: colors.primary)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.cardGlassBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.admin_panel_settings_rounded, color: colors.primary, size: 34),
                  ),
                  const SizedBox(height: 24),
                  Text('Enter Admin PIN',
                      style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: colors.onSurface)),
                  const SizedBox(height: 8),
                  Text('Enter your 4-digit PIN to access the admin panel',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: colors.onSurfaceVariant)),
                  const SizedBox(height: 32),

                  // PIN boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _AdminPinBox(
                      controller: _pinControllers[i],
                      focusNode: _pinFocusNodes[i],
                      hasError: _pinError != null,
                      enabled: !_pinLoading,
                      onChanged: (v) => _onPinDigit(i, v),
                      onBackspace: () => _onPinBackspace(i),
                      colors: colors,
                    )),
                  ),

                  // Error message
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _pinError != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(_pinError!,
                                      style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  if (_pinLoading) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

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

class _AdminPinBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final AppColors colors;

  const _AdminPinBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
    required this.onBackspace,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? Colors.redAccent.withValues(alpha: 0.6)
              : focusNode.hasFocus
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.3),
          width: focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.sora(
              fontSize: 22, fontWeight: FontWeight.w700, color: colors.onSurface),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          onChanged: onChanged,
        ),
      ),
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
