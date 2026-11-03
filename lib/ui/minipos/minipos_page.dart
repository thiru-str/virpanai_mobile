import 'package:waioz/ui/minipos/minipos_scan_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waioz/api/minipos_service.dart';
import 'package:waioz/ui/minipos/minipos_cart_page.dart';
import 'package:waioz/ui/minipos/minipos_orders_page.dart';
import 'package:waioz/ui/minipos/minipos_settings_page.dart';
import 'package:waioz/ui/minipos/minipos_temp_cart.dart';
import 'package:waioz/ui/minipos/minipos_sell_page.dart';
import 'package:waioz/ui/minipos/minipos_vendor_page.dart';
import 'package:waioz/ui/minipos/minipos_widgets.dart';
import 'package:waioz/utility/app_colors.dart';

/// MiniPOS home: vendor connection status and quick actions.
class MiniPosPage extends StatefulWidget {
  /// Called by the back arrow when the page is shown inside the bottom-nav shell.
  final VoidCallback? onBack;
  const MiniPosPage({super.key, this.onBack});
  @override
  State<MiniPosPage> createState() => _MiniPosPageState();
}

class _MiniPosPageState extends State<MiniPosPage> {
  final _api = MiniPosService.instance;
  bool _loading = true;
  bool _scanning = false;
  bool _checkingConnection = false;

  bool get _salesEnabled =>
      _connected && !_loading && !_checkingConnection && _error == null;
  String? _error;
  String _vendorStatus = 'not_submitted';
  bool _connected = false;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _connected = false;
      _cartCount = 0;
    });
    try {
      await MiniPosTempCart.instance.bindToCurrentAccount();
      final status = await _api.get('minipos/status');
      if (status['enabled'] != true) {
        MiniPosTempCart.instance.clear();
        throw const MiniPosException('MiniPOS is not enabled');
      }
      if (!mounted) return;
      setState(() {
        _vendorStatus = '${status['vendor_status'] ?? 'not_submitted'}';
        _connected = status['can_checkout'] == true;
      });
      // Mapped inventory stays on the server, but POS stays locked until connected.
      if (!_connected) {
        MiniPosTempCart.instance.clear();
        return;
      }
      MiniPosTempCart.instance.setPlatformFee(
          int.tryParse('${status['platform_fee_paise'] ?? 0}') ?? 0);
      if (!mounted) return;
      setState(() {
        _vendorStatus = '${status['vendor_status'] ?? 'not_submitted'}';
        _connected = status['can_checkout'] == true;
        _cartCount = MiniPosTempCart.instance.itemCount;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _canProceed() async {
    if (!_salesEnabled) return false;
    setState(() => _checkingConnection = true);
    try {
      final status = await _api.get('minipos/status');
      MiniPosTempCart.instance.setPlatformFee(
          int.tryParse('${status['platform_fee_paise'] ?? 0}') ?? 0);
      if (!mounted) return false;
      final connected =
          status['enabled'] == true && status['can_checkout'] == true;
      setState(() {
        _connected = connected;
        _vendorStatus = '${status['vendor_status'] ?? 'not_submitted'}';
        if (!connected) {
          MiniPosTempCart.instance.clear();
          _cartCount = 0;
        }
      });
      if (!connected)
        miniPosMessage(context, 'Connect your vendor account to use MiniPOS.');
      return connected;
    } catch (e) {
      if (mounted) {
        miniPosMessage(context, e);
        await _load();
      }
      return false;
    } finally {
      if (mounted) setState(() => _checkingConnection = false);
    }
  }

  Future<void> _openSales(Widget page) async {
    if (await _canProceed() && mounted) await _open(page);
  }

  Future<void> _scan() async {
    if (_scanning || !await _canProceed() || !mounted) return;
    setState(() => _scanning = true);
    try {
      final cart = await scanMiniPosPhone(context);
      if (!mounted || cart == null) return;
      await _open(const MiniPosCartPage());
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _load(); // Cart count and status may have changed.
  }

  void _back() {
    // Read onBack at tap time; a callback captured at build time can be stale.
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) => MiniPosScaffold(
        appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: _back),
            title: const Text('MiniPOS',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            actions: [
              if (_connected && !_loading && _error == null) ...[
                IconButton(
                    tooltip: 'Scan product IMEI',
                    onPressed: !_salesEnabled || _scanning ? null : _scan,
                    icon: const Icon(Icons.qr_code_scanner)),
                Badge(
                    isLabelVisible: _cartCount > 0,
                    label: Text('$_cartCount'),
                    child: IconButton(
                        tooltip: 'MiniPOS cart',
                        onPressed: _salesEnabled
                            ? () => _openSales(const MiniPosCartPage())
                            : null,
                        icon: const Icon(Icons.shopping_cart_outlined))),
                const SizedBox(width: 8),
              ],
            ]),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? MiniPosUnavailable(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    onRefresh: _load,
                    child: LayoutBuilder(builder: (context, constraints) {
                      // Stretch the action tiles so the page fills the screen.
                      const fixed = 16 + 168 + 14 + 24 + 12 + 12 + 16;
                      final tileHeight = ((constraints.maxHeight - fixed) / 2)
                          .clamp(120.0, 170.0);
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _VendorBanner(
                            status: _vendorStatus,
                            connected: _connected,
                            onTap: () => _open(const MiniPosVendorPage()),
                          ),
                          if (!_connected) ...[
                            const SizedBox(height: 12),
                            _VendorConnectionTip(status: _vendorStatus),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 24,
                            child: Text('Quick Actions',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 12),
                          _ActionRow(height: tileHeight, tiles: [
                            _ActionTile(
                                icon: Icons.storefront_outlined,
                                title: 'Products',
                                onTap: _salesEnabled
                                    ? () => _open(const MiniPosSellPage())
                                    : null),
                            _ActionTile(
                                icon: Icons.assignment_outlined,
                                title: 'Orders',
                                onTap: _salesEnabled
                                    ? () => _open(const MiniPosOrdersPage())
                                    : null),
                          ]),
                          const SizedBox(height: 12),
                          _ActionRow(height: tileHeight, tiles: [
                            _ActionTile(
                                icon: Icons.settings_outlined,
                                title: 'Settings',
                                onTap: _salesEnabled
                                    ? () => _open(const MiniPosSettingsPage())
                                    : null),
                            _ActionTile(
                                icon: Icons.badge_outlined,
                                title: 'Vendor details',
                                onTap: _salesEnabled
                                    ? () => _open(const MiniPosVendorPage())
                                    : null),
                          ]),
                        ],
                      );
                    }),
                  ),
      );
}

const _cardRadius = BorderRadius.all(Radius.circular(16));

BoxDecoration _cardDecoration() => BoxDecoration(
      borderRadius: _cardRadius,
      border: Border.all(color: AppColors.primary),
    );

/// Explains why sales are unavailable without asking verifying vendors to reapply.
class _VendorConnectionTip extends StatelessWidget {
  final String status;
  const _VendorConnectionTip({required this.status});

  @override
  Widget build(BuildContext context) {
    final verifying =
        ['pending_admin', 'submitting', 'processing'].contains(status);
    final color = AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.08), Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              verifying
                  ? Icons.hourglass_top_rounded
                  : Icons.info_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verifying
                      ? 'Vendor verification in progress'
                      : 'Connect your vendor account',
                  style: TextStyle(
                      color: color, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  verifying
                      ? 'Your vendor details are being verified. Products, orders and sales will unlock once connected.'
                      : 'Add your vendor details to unlock products, orders and sales in MiniPOS.',
                  style: const TextStyle(
                      color: Color(0xFF454545), fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand-coloured vendor connection banner.
class _VendorBanner extends StatelessWidget {
  final String status;
  final bool connected;
  final VoidCallback onTap;
  const _VendorBanner(
      {required this.status, required this.connected, required this.onTap});

  (String, String, IconData, Color) get _state {
    if (connected) {
      return (
        'Connected',
        'Payments settle to your bank account',
        Icons.check_circle,
        const Color(0xFF1E8E3E)
      );
    }
    switch (status) {
      case 'pending_admin':
      case 'submitting':
      case 'processing':
        return (
          'Verifying',
          'Your vendor details are being verified',
          Icons.hourglass_top_rounded,
          const Color(0xFFB26A00)
        );
      default:
        return (
          'Not connected',
          'Add your vendor details to accept payments',
          Icons.link_off,
          const Color(0xFF5F6368)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, hint, icon, color) = _state;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: _cardRadius,
        onTap: onTap,
        child: Ink(
          height: 168,
          decoration: BoxDecoration(
            borderRadius: _cardRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                Color.lerp(AppColors.primary, Colors.black, 0.25)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.badge_outlined,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text('Vendor',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 14),
                    // Connection badge sits on the left under the title.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 4),
                        Text(label,
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Text(hint,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13)),
                  ]),
            ),
            const SizedBox(width: 12),
            // Round arrow: tap to open vendor details.
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right_rounded,
                  size: 28, color: AppColors.primary),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Two equal action tiles side by side at a fixed height.
class _ActionRow extends StatelessWidget {
  final double height;
  final List<Widget> tiles;
  const _ActionRow({required this.height, required this.tiles});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Row(children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: tiles[i]),
          ],
        ]),
      );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: _cardRadius,
          onTap: onTap,
          child: Ink(
            decoration: _cardDecoration(),
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color:
                      onTap == null ? Colors.grey.shade400 : AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 14),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}
