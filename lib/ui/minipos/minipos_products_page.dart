import 'package:flutter/material.dart';
import 'package:waioz/ui/minipos/minipos_sell_page.dart';

/// Price browsing follows the same MOP-first, read-only product display.
/// Per-sale overrides are available only in the MiniPOS cart.
class MiniPosProductsPage extends StatelessWidget {
  const MiniPosProductsPage({super.key});

  @override
  Widget build(BuildContext context) => const MiniPosSellPage();
}
