import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class MiniPosSettingsPage extends StatefulWidget {
  const MiniPosSettingsPage({super.key});
  @override
  State<MiniPosSettingsPage> createState() => _MiniPosSettingsPageState();
}

class _MiniPosSettingsPageState extends State<MiniPosSettingsPage> {
  bool _loading = true, _configured = false, _editing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MiniPosService.instance.get('minipos/owner-pin');
      if (mounted) setState(() => _configured = result['configured'] == true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    if (_editing) return;
    setState(() => _editing = true);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PinDialog(configured: _configured),
    );
    if (!mounted) return;
    setState(() => _editing = false);
    if (saved == true) miniPosMessage(context, 'PIN saved');
    await _load();
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
        appBar: AppBar(title: const Text('MiniPOS Settings')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : ListView(padding: const EdgeInsets.all(20), children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.primary)),
                      child: ListTile(
                        leading:
                            Icon(Icons.lock_outline, color: AppColors.primary),
                        title: Text(_configured ? 'Change PIN' : 'Set PIN'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _editing ? null : _edit,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RichText(
                        text: TextSpan(
                          style: FontUtils.primaryFontStyle(
                              fontSize: 12, color: Colors.black),
                          children: const [
                            TextSpan(
                                text: 'Note: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    'If you forgot your PIN, please contact GoWelMart support.'),
                          ],
                        ),
                      ),
                    ),
                  ]),
      );
}

class _PinDialog extends StatefulWidget {
  final bool configured;
  const _PinDialog({required this.configured});
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> with WidgetsBindingObserver {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _hidden = [true, true, true];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _old.clear();
      _new.clear();
      _confirm.clear();
      if (mounted)
        setState(() {
          _hidden.fillRange(0, 3, true);
        });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await MiniPosService.instance.post('minipos/owner-pin', {
        if (widget.configured) 'old_pin': _old.text,
        'new_pin': _new.text,
        'confirm_pin': _confirm.text,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String label, TextEditingController controller, int index) =>
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextFormField(
          controller: controller,
          enabled: !_saving,
          obscureText: _hidden[index],
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.number,
          textInputAction:
              index == 2 ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted: index == 2 ? (_) => _save() : null,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4)
          ],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _hidden[index] ? 'Show PIN' : 'Hide PIN',
              onPressed: _saving
                  ? null
                  : () => setState(() => _hidden[index] = !_hidden[index]),
              icon: Icon(_hidden[index]
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              color: AppColors.primary,
            ),
          ),
          validator: (value) {
            if (!RegExp(r'^\d{4}$').hasMatch(value ?? ''))
              return 'Enter a 4-digit PIN';
            if (index == 2 && value != _new.text) return 'PINs do not match';
            return null;
          },
        ),
      );

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AppColors.primary)),
        child: PopScope(
          canPop: !_saving,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(widget.configured ? 'Change PIN' : 'Set PIN'),
            content: SingleChildScrollView(
                child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.configured) _field('Old PIN', _old, 0),
                        _field('New PIN', _new, 1),
                        _field('Confirm New PIN', _confirm, 2),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(_error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                      ],
                    ))),
            actions: [
              TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save PIN'),
              ),
            ],
          ),
        ),
      );
}
