import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class AdminPinDialog extends StatefulWidget {
  const AdminPinDialog({super.key});

  /// Shows the PIN dialog. Returns `true` if the correct PIN was entered.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdminPinDialog(),
    );
    return result == true;
  }

  @override
  State<AdminPinDialog> createState() => _AdminPinDialogState();
}

class _AdminPinDialogState extends State<AdminPinDialog>
    with SingleTickerProviderStateMixin {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes  = List.generate(4, (_) => FocusNode());

  bool _loading = false;
  String? _error;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes)  { f.dispose(); }
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
    }
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_pin.length == 4) {
      _verify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });

    try {
      final row = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', 'admin_pin')
          .single();
      final correctPin = row['value']?.toString() ?? '';

      if (!mounted) return;

      if (_pin == correctPin) {
        Navigator.of(context).pop(true);
      } else {
        _triggerShake('Incorrect PIN. Try again.');
      }
    } catch (_) {
      if (mounted) _triggerShake('Could not verify PIN. Check connection.');
    }
  }

  void _triggerShake(String message) {
    setState(() {
      _loading = false;
      _error = message;
    });
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.12),
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: colors.primary, size: 30),
            ),
            const SizedBox(height: 20),
            Text('Admin Access',
                style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface)),
            const SizedBox(height: 6),
            Text('Enter your 4-digit PIN to continue',
                style: GoogleFonts.inter(
                    fontSize: 13, color: colors.onSurfaceVariant)),
            const SizedBox(height: 28),

            // PIN boxes
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _PinBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  hasError: _error != null,
                  enabled: !_loading,
                  onChanged: (v) => _onDigitChanged(i, v),
                  onBackspace: () => _onBackspace(i),
                  colors: colors,
                )),
              ),
            ),

            // Error
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 14, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(_error!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Cancel
            TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(false),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: colors.onSurfaceVariant)),
            ),

            if (_loading) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final AppColors colors;

  const _PinBox({
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
