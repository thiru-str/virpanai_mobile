import 'package:flutter/material.dart';
import '../../../../model/block_config.dart';
import '../../../../utility/app_colors.dart';
import '../../../../utility/font_utils.dart';
import '../../../../utility/common_html.dart';

/// Description1 - Accordion-style expandable product description.
/// Extracted from product_detail_page.dart buildProductDescription()
class Description1Widget extends StatefulWidget {
  final String? description;
  final String? additionalDescription;
  final BlockConfig config;

  const Description1Widget({
    super.key,
    this.description,
    this.additionalDescription,
    required this.config,
  });

  @override
  State<Description1Widget> createState() => _Description1WidgetState();
}

class _Description1WidgetState extends State<Description1Widget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if ((widget.description == null || widget.description!.isEmpty) &&
        (widget.additionalDescription == null || widget.additionalDescription!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accordion header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Description',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textColor50,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.description != null && widget.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CommonHtmlWidget(htmlContent: widget.description!),
                  ),
                if (widget.additionalDescription != null &&
                    widget.additionalDescription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CommonHtmlWidget(htmlContent: widget.additionalDescription!),
                  ),
                ],
              ],
            ),
            crossFadeState:
                _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
