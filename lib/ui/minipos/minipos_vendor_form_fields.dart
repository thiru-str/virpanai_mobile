import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

InputDecoration _decoration(String label, {String? prefixText}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
  );
  return InputDecoration(
    labelText: label,
    prefixText: prefixText,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border,
    disabledBorder: border.copyWith(
        borderSide:
            BorderSide(color: AppColors.primary.withValues(alpha: 0.15))),
    focusedBorder: border.copyWith(
        borderSide: BorderSide(color: AppColors.primary, width: 2)),
  );
}

/// No automatic keyboard capitalization or input case conversion. The backend
/// normalizes identifiers such as IFSC/PAN for Cashfree, not the user's typing.
class MiniPosVendorTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final bool enabled, validateOnChange;
  final String? prefixText;
  final List<TextInputFormatter>? formatters;
  const MiniPosVendorTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboard,
    this.enabled = true,
    this.validateOnChange = false,
    this.prefixText,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        autovalidateMode: validateOnChange
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        keyboardType: keyboard,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: formatters,
        decoration: _decoration(label, prefixText: prefixText),
      );
}

String miniPosVendorOptionLabel(String value) => switch (value) {
      'BUSINESS' => 'Business',
      'INDIVIDUAL' => 'Individual',
      _ => value.replaceAll('_', ' '),
    };

/// A branded, wrapping form control. Canonical provider values are preserved;
/// selection happens in a searchable sheet rather than a platform dropdown.
class MiniPosVendorSelectField extends FormField<String> {
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  MiniPosVendorSelectField({
    super.key,
    required this.label,
    required String? value,
    required this.items,
    required this.onChanged,
    bool enabled = true,
  }) : super(
          initialValue: value,
          enabled: enabled,
          validator: (value) => value == null || !items.contains(value)
              ? 'Select ${label.toLowerCase()}'
              : null,
          builder: (state) => _buildField(state),
        );

  @override
  FormFieldState<String> createState() => _MiniPosVendorSelectState();

  static Widget _buildField(FormFieldState<String> state) {
    final field = state.widget as MiniPosVendorSelectField;
    final selected = state.value;
    return Semantics(
      button: true,
      enabled: field.enabled,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: !field.enabled
            ? null
            : () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final value = await showModalBottomSheet<String>(
                  context: state.context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom),
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      child: MiniPosTheme(
                        child: SafeArea(
                          top: false,
                          child: _VendorOptionsSheet(
                              label: field.label,
                              items: field.items,
                              value: selected),
                        ),
                      ),
                    ),
                  ),
                );
                if (!state.mounted || value == null) return;
                final current = state.widget as MiniPosVendorSelectField;
                if (!current.enabled || !current.items.contains(value)) return;
                state.didChange(value);
                current.onChanged(value);
              },
        child: InputDecorator(
          isEmpty: selected == null,
          decoration: _decoration(field.label).copyWith(
            enabled: field.enabled,
            errorText: state.errorText,
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                selected == null ? '' : miniPosVendorOptionLabel(selected),
                style: TextStyle(
                    color:
                        field.enabled ? AppColors.textColor : Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: field.enabled ? AppColors.primary : Colors.black38),
          ]),
        ),
      ),
    );
  }
}

class _MiniPosVendorSelectState extends FormFieldState<String> {
  @override
  void didUpdateWidget(covariant MiniPosVendorSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

class _VendorOptionsSheet extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? value;
  const _VendorOptionsSheet(
      {required this.label, required this.items, required this.value});

  @override
  State<_VendorOptionsSheet> createState() => _VendorOptionsSheetState();
}

class _VendorOptionsSheetState extends State<_VendorOptionsSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => miniPosVendorOptionLabel(item)
            .toLowerCase()
            .contains(_search.trim().toLowerCase()))
        .toList();
    // Header/search scroll too, so large fonts plus an open keyboard cannot
    // overflow a fixed-height Column on short or landscape displays.
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
          child: Column(children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          child: Row(children: [
            Expanded(
                child: Text('Select ${widget.label.toLowerCase()}',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700))),
            IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
        ),
        if (widget.items.length > 6)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: _decoration('Search ${widget.label.toLowerCase()}')
                  .copyWith(
                      prefixIcon: Icon(Icons.search, color: AppColors.primary)),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
      ])),
      if (filtered.isEmpty)
        const SliverToBoxAdapter(
            child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No matching options')),
        ))
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverList.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final item = filtered[index];
              final selected = item == widget.value;
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                selected: selected,
                selectedColor: AppColors.primary,
                selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                title: Text(miniPosVendorOptionLabel(item)),
                trailing: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.primary : Colors.black38),
                onTap: () => Navigator.pop(context, item),
              );
            },
          ),
        ),
    ]);
  }
}
