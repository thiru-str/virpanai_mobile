import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waioz/api/api_service.dart';
import 'package:waioz/model/customer_list_response.dart';
import 'package:waioz/ui/dealer_order_cart_page.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

Future<void> showDealerOrderCustomerDrawer(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => DealerOrderCustomerDrawer(
      onStarted: (customer, cart) {
        Navigator.of(sheetContext).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DealerOrderProductsPage(
            customer: customer,
            initialCart: cart,
          ),
        ));
      },
    ),
  );
}

class DealerOrderCustomerDrawer extends StatefulWidget {
  final void Function(Customer customer, Map<String, dynamic> cart) onStarted;
  const DealerOrderCustomerDrawer({super.key, required this.onStarted});

  @override
  State<DealerOrderCustomerDrawer> createState() =>
      _DealerOrderCustomerDrawerState();
}

class _DealerOrderCustomerDrawerState extends State<DealerOrderCustomerDrawer> {
  final ApiService _api = ApiService();
  List<Customer> _customers = [];
  bool _loading = true;
  String? _startingCustomerId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final response =
          await _api.getCustomerList(context, limit: 100, offset: 0);
      if (mounted) setState(() => _customers = response.customers ?? []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectCustomer(Customer customer) async {
    if (customer.id == null) return;
    setState(() => _startingCustomerId = customer.id);
    try {
      final result = await _api.startDealerOrderCart(context, customer.id!);
      if (!mounted) return;
      widget.onStarted(
          customer, Map<String, dynamic>.from(result['cart'] ?? {}));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start the dealer order.')),
        );
    } finally {
      if (mounted) setState(() => _startingCustomerId = null);
    }
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        heightFactor: 0.82,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select customer',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: FontUtils.primaryFontStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.secondary,
                  prefixIcon: Icon(Icons.search, color: AppColors.textColor50),
                  hintText: 'Search customer or shop name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : ListView.separated(
                      itemCount: _customers.where((customer) {
                        final query = _searchQuery.trim().toLowerCase();
                        if (query.isEmpty) return true;
                        return [
                          customer.metadata?.shopName,
                          customer.companyName,
                          customer.firstName,
                          customer.lastName,
                          customer.phone,
                          customer.email,
                        ].whereType<String>().any(
                            (value) => value.toLowerCase().contains(query));
                      }).length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final customers = _customers.where((customer) {
                          final query = _searchQuery.trim().toLowerCase();
                          if (query.isEmpty) return true;
                          return [
                            customer.metadata?.shopName,
                            customer.companyName,
                            customer.firstName,
                            customer.lastName,
                            customer.phone,
                            customer.email
                          ].whereType<String>().any(
                              (value) => value.toLowerCase().contains(query));
                        }).toList();
                        final customer = customers[index];
                        final title = customer.metadata?.shopName ??
                            customer.companyName ??
                            customer.firstName ??
                            'Customer';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: customer.metadata
                                        ?.shopNameBoardImage?.isNotEmpty ==
                                    true
                                ? NetworkImage(
                                    customer.metadata!.shopNameBoardImage!)
                                : null,
                            child: customer.metadata?.shopNameBoardImage
                                        ?.isNotEmpty ==
                                    true
                                ? null
                                : const Icon(Icons.storefront_outlined),
                          ),
                          title: Text(
                            title,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          subtitle: Text(customer.phone ?? customer.email ?? '',
                              style: FontUtils.primaryFontStyle(
                                fontSize: 13,
                                color: AppColors.textColor50,
                              )),
                          trailing: _startingCustomerId == customer.id
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.chevron_right,
                                  color: AppColors.primary),
                          onTap: _startingCustomerId == null
                              ? () => _selectCustomer(customer)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
}

class DealerOrderProductsPage extends StatefulWidget {
  final Customer customer;
  final Map<String, dynamic> initialCart;
  const DealerOrderProductsPage(
      {super.key, required this.customer, required this.initialCart});

  @override
  State<DealerOrderProductsPage> createState() =>
      _DealerOrderProductsPageState();
}

class _DealerOrderProductsPageState extends State<DealerOrderProductsPage> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _productScrollController = ScrollController();
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  List<dynamic> _collections = [];
  List<dynamic> _brands = [];
  late Map<String, dynamic> _cart;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMoreProducts = true;
  String? _addingVariantId;
  String _categoryId = '';
  String _collectionId = '';
  String _brandId = '';
  String _order = '';
  int _filterSection = 0;
  String _filterSearch = '';
  int _page = 0;
  static const int _limit = 12;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _cart = widget.initialCart;
    _productScrollController.addListener(_onProductScroll);
    _loadFilters();
    _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _productScrollController
      ..removeListener(_onProductScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final response = await _api.getDealerOrderProductFilters(context);
      if (mounted) {
        List<dynamic> alphabetically(List<dynamic> items, String field) {
          final sorted = [...items];
          sorted.sort((left, right) => (left as Map)[field]
              .toString()
              .toLowerCase()
              .compareTo((right as Map)[field].toString().toLowerCase()));
          return sorted;
        }

        setState(() {
          _categories =
              alphabetically(response['categories'] as List? ?? [], 'name');
          _collections =
              alphabetically(response['collections'] as List? ?? [], 'title');
          _brands = alphabetically(response['brands'] as List? ?? [], 'value');
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMoreProducts = true;
    } else if (_loadingMore || !_hasMoreProducts) {
      return;
    }
    if (mounted) {
      setState(() {
        if (reset) {
          _loading = true;
        } else {
          _loadingMore = true;
        }
      });
    }
    try {
      final response = await _api.getDealerOrderProducts(
        context,
        cartId: _cart['id']?.toString() ?? '',
        search: _searchController.text.trim(),
        categoryId: _categoryId,
        collectionId: _collectionId,
        brandId: _brandId,
        order: _order,
        limit: _limit,
        offset: _page * _limit,
      );
      final rawProducts = response['products'] as List<dynamic>? ?? [];
      final products = rawProducts
          .map((raw) {
            final product = Map<String, dynamic>.from(raw as Map);
            final variants = (product['variants'] as List<dynamic>? ?? [])
                .where((rawVariant) =>
                    _variantStock(
                        Map<String, dynamic>.from(rawVariant as Map)) >
                    0)
                .toList();
            product['variants'] = variants;
            return product;
          })
          .where((product) => (product['variants'] as List<dynamic>).isNotEmpty)
          .toList();
      if (mounted) {
        setState(() {
          if (reset) {
            _products = products;
          } else {
            final existingIds =
                _products.map((raw) => (raw as Map)['id'].toString()).toSet();
            _products.addAll(products.where(
                (product) => !existingIds.contains(product['id'].toString())));
          }
          _hasMoreProducts = rawProducts.length == _limit;
        });
        if (products.isEmpty && rawProducts.length == _limit) {
          _page++;
          Future<void>.delayed(Duration.zero, () => _loadProducts());
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
        if (_hasMoreProducts) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _onProductScroll());
        }
      }
    }
  }

  void _onProductScroll() {
    if (!_productScrollController.hasClients ||
        _productScrollController.position.extentAfter > 300 ||
        _loading ||
        _loadingMore ||
        !_hasMoreProducts) {
      return;
    }
    _page++;
    _loadProducts();
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadProducts(reset: true);
    });
  }

  num _variantPrice(Map<String, dynamic> variant) {
    final calculatedPrice = variant['calculated_price'] as Map?;
    return calculatedPrice?['calculated_amount'] ??
        calculatedPrice?['original_amount'] ??
        0;
  }

  int _variantStock(Map<String, dynamic> variant) {
    return (variant['inventory_quantity'] as num?)?.toInt() ??
        (variant['available_quantity'] as num?)?.toInt() ??
        0;
  }

  bool _isDefaultVariant(Map<String, dynamic> variant) {
    final title = variant['title']?.toString().trim().toLowerCase() ?? '';
    return title.isEmpty || title == 'default variant';
  }

  String _variantSpecifications(Map<String, dynamic> variant) {
    final options = variant['options'] as List<dynamic>? ?? [];
    final values = options
        .map((raw) {
          final option = raw as Map;
          final optionDefinition = option['option'] as Map?;
          final title = optionDefinition?['title']?.toString();
          final value = option['value']?.toString();
          if (title != null &&
              title.isNotEmpty &&
              value != null &&
              value.isNotEmpty) {
            return '$title: $value';
          }
          return value ?? '';
        })
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isNotEmpty) return values.join(' · ');
    final sku = variant['sku']?.toString();
    return sku == null || sku.isEmpty ? 'Standard specification' : 'SKU: $sku';
  }

  Future<void> _addProduct(Map<String, dynamic> variant) async {
    final cartId = _cart['id'] as String?;
    final variantId = variant['id'] as String?;
    if (cartId == null || variantId == null) return;
    setState(() => _addingVariantId = variantId);
    try {
      final response =
          await _api.addDealerOrderItem(context, cartId, variantId);
      if (mounted)
        setState(
            () => _cart = Map<String, dynamic>.from(response['cart'] ?? _cart));
    } catch (_) {
      // The shared API layer shows the backend error in the app toast.
    } finally {
      if (mounted) setState(() => _addingVariantId = null);
    }
  }

  void _clearFilters() {
    setState(() {
      _collectionId = '';
      _categoryId = '';
      _brandId = '';
      _order = '';
    });
  }

  Future<void> _openCartPage() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DealerOrderCartPage(initialCart: _cart),
    ));
    final cartId = _cart['id']?.toString();
    if (cartId == null || !mounted) return;
    try {
      final response = await _api.getDealerOrderCart(context, cartId);
      if (mounted) {
        setState(
            () => _cart = Map<String, dynamic>.from(response['cart'] ?? _cart));
      }
    } catch (_) {
      // Shared API layer displays the backend error.
    }
  }

  Widget _buildFilterOptions(VoidCallback refresh) {
    if (_filterSection == 3) {
      const sortOptions = <String, String>{
        'price': 'Lowest – Highest Price',
        '-price': 'Highest – Lowest Price',
      };
      return ListView(
        children: sortOptions.entries
            .map((entry) => ListTile(
                  dense: true,
                  leading: Icon(
                    _order == entry.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        _order == entry.key ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(entry.value,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      )),
                  onTap: () {
                    _order = entry.key;
                    refresh();
                  },
                ))
            .toList(),
      );
    }

    final List<dynamic> values;
    final String selectedId;
    if (_filterSection == 0) {
      values = _collections;
      selectedId = _collectionId;
    } else if (_filterSection == 1) {
      values = _categories;
      selectedId = _categoryId;
    } else {
      values = _brands;
      selectedId = _brandId;
    }

    final visibleValues = values.where((raw) {
      final item = raw as Map;
      final label =
          (item['title'] ?? item['name'] ?? item['value'] ?? '').toString();
      return label.toLowerCase().contains(_filterSearch.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            key: ValueKey(_filterSection),
            onChanged: (value) {
              _filterSearch = value;
              refresh();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.secondary,
              isDense: true,
              prefixIcon: Icon(Icons.search, color: AppColors.textColor50),
              hintText: _filterSection == 0
                  ? 'Search collections'
                  : _filterSection == 1
                      ? 'Search categories'
                      : 'Search brands',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visibleValues.length,
            itemBuilder: (_, index) {
              final item = visibleValues[index] as Map;
              final id = item['id'].toString();
              final label =
                  (item['title'] ?? item['name'] ?? item['value'] ?? '')
                      .toString();
              return CheckboxListTile(
                value: selectedId == id,
                activeColor: AppColors.primary,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(label,
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    )),
                onChanged: (_) {
                  if (_filterSection == 0) {
                    _collectionId = selectedId == id ? '' : id;
                  } else if (_filterSection == 1) {
                    _categoryId = selectedId == id ? '' : id;
                  } else {
                    _brandId = selectedId == id ? '' : id;
                  }
                  refresh();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    _filterSearch = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (_, refresh) => _buildFilterDrawer(sheetContext, refresh),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext sheetContext, StateSetter refresh) {
    const sections = ['Collections', 'Categories', 'Brands', 'Sort by'];
    return FractionallySizedBox(
      heightFactor: .9,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text('Filter products',
                        textAlign: TextAlign.center,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        )),
                  ),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      refresh(() {});
                    },
                    child: Text('Clear all',
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          color: Colors.red,
                        )),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 118,
                    child: ColoredBox(
                      color: AppColors.secondary,
                      child: ListView.builder(
                        itemCount: sections.length,
                        itemBuilder: (_, index) => InkWell(
                          onTap: () => refresh(() {
                            _filterSection = index;
                            _filterSearch = '';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 18),
                            decoration: BoxDecoration(
                              color: _filterSection == index
                                  ? AppColors.primary.withValues(alpha: .12)
                                  : null,
                              border: Border(
                                left: BorderSide(
                                  color: _filterSection == index
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              sections[index],
                              style: FontUtils.primaryFontStyle(
                                fontSize: 14,
                                color: AppColors.textColor,
                                fontWeight: _filterSection == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildFilterOptions(() => refresh(() {}))),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textColor,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        setState(() {});
                        _loadProducts(reset: true);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart['items'] as List<dynamic>? ?? [];
    final count = items.fold<int>(
        0, (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ),
        title: Text(
          widget.customer.metadata?.shopName ?? 'Create order',
          style: FontUtils.primaryFontStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        actions: [
          Badge(
            backgroundColor: AppColors.primary,
            label: Text('$count'),
            isLabelVisible: count > 0,
            child: IconButton(
              onPressed: _openCartPage,
              icon:
                  Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _openCartPage,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'View cart · $count items',
                    style: FontUtils.primaryFontStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: FontUtils.primaryFontStyle(fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.secondary,
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.textColor50),
                      hintText: 'Search products',
                      hintStyle: FontUtils.primaryFontStyle(
                          fontSize: 14, color: AppColors.textColor50),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: [_collectionId, _categoryId, _brandId]
                      .where((value) => value.isNotEmpty)
                      .isNotEmpty,
                  label: Text('${[
                    _collectionId,
                    _categoryId,
                    _brandId
                  ].where((value) => value.isNotEmpty).length}'),
                  child: IconButton.outlined(
                    tooltip: 'Filters',
                    onPressed: _showFilters,
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.tune),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _products.isEmpty
                    ? Center(
                        child: Text('No products found',
                            style: FontUtils.primaryFontStyle(
                              fontSize: 15,
                              color: AppColors.textColor50,
                            )))
                    : ListView.separated(
                        controller: _productScrollController,
                        padding: const EdgeInsets.all(12),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: _products.length + 1,
                        itemBuilder: (_, index) {
                          if (index == _products.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _loadingMore
                                    ? CircularProgressIndicator(
                                        color: AppColors.primary)
                                    : Text(
                                        _hasMoreProducts
                                            ? 'Scroll to load more products'
                                            : 'All available products loaded',
                                        style: FontUtils.primaryFontStyle(
                                          fontSize: 13,
                                          color: AppColors.textColor50,
                                        )),
                              ),
                            );
                          }
                          final product = Map<String, dynamic>.from(
                              _products[index] as Map);
                          final variants =
                              product['variants'] as List<dynamic>? ?? [];
                          if (variants.isEmpty) return const SizedBox.shrink();
                          final defaultOnly = variants.length == 1 &&
                              _isDefaultVariant(Map<String, dynamic>.from(
                                  variants.first as Map));
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 82,
                                    height: 82,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: product['thumbnail'] == null
                                        ? const Icon(Icons.inventory_2_outlined,
                                            size: 38)
                                        : Image.network(
                                            product['thumbnail'].toString(),
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                    Icons.inventory_2_outlined),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['title']?.toString() ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: FontUtils.primaryFontStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textColor),
                                        ),
                                        if (!defaultOnly)
                                          Text(
                                            '${variants.length} ${variants.length == 1 ? 'variant' : 'variants'}',
                                            style: FontUtils.primaryFontStyle(
                                              fontSize: 12,
                                              color: AppColors.textColor50,
                                            ),
                                          ),
                                        SizedBox(height: defaultOnly ? 12 : 8),
                                        ...variants.map((raw) {
                                          final variant =
                                              Map<String, dynamic>.from(
                                                  raw as Map);
                                          final variantId =
                                              variant['id'].toString();
                                          final stock = _variantStock(variant);
                                          final isUpdating =
                                              _addingVariantId == variantId;
                                          return Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: defaultOnly ? 0 : 10),
                                            decoration: defaultOnly
                                                ? null
                                                : BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                  ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (!defaultOnly) ...[
                                                  Text(
                                                    variant['title']
                                                            ?.toString() ??
                                                        '',
                                                    style: FontUtils
                                                        .primaryFontStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _variantSpecifications(
                                                        variant),
                                                    style: FontUtils
                                                        .primaryFontStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.textColor50,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                ],
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '₹${_variantPrice(variant)}',
                                                            style: FontUtils
                                                                .primaryFontStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 36,
                                                      child:
                                                          ElevatedButton.icon(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          elevation: 0,
                                                          foregroundColor:
                                                              AppColors.primary,
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .primary),
                                                          ),
                                                        ),
                                                        onPressed: stock > 0 &&
                                                                !isUpdating
                                                            ? () => _addProduct(
                                                                variant)
                                                            : null,
                                                        icon: isUpdating
                                                            ? const SizedBox(
                                                                width: 14,
                                                                height: 14,
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2))
                                                            : const Icon(
                                                                Icons.add,
                                                                size: 16),
                                                        label:
                                                            const Text('Add'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
