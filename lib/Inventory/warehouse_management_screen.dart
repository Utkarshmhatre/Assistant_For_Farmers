import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_assistx/Inventory/inventory_provider.dart';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  _WarehouseManagementScreenState createState() =>
      _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  String _sortOption = 'Name';
  bool _showPieChartForDistribution = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      provider.loadWarehouse().then((_) => provider.seedDummyDataIfEmpty());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Warehouse Assistant'),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
          body: inventoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildOverviewTab(inventoryProvider),
                    _buildProductListTab(inventoryProvider),
                    _OptimizedAnalyticsTab(
                      inventoryProvider: inventoryProvider,
                      showPieChart: _showPieChartForDistribution,
                      onToggleChart: (value) =>
                          setState(() => _showPieChartForDistribution = value),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddProductDialog(context),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: scheme.surface,
            selectedItemColor: scheme.primary,
            unselectedItemColor: scheme.onSurfaceVariant,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Overview'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Products'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: 'Analytics'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(InventoryProvider inventoryProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCapacityIndicator(inventoryProvider),
          const SizedBox(height: 24),
          _buildExpiryAlerts(inventoryProvider),
          const SizedBox(height: 24),
          _buildQuickTips(inventoryProvider),
        ],
      ),
    );
  }

  Widget _buildCapacityIndicator(InventoryProvider inventoryProvider) {
    final capacity = inventoryProvider.warehouse?.capacity ?? 0;
    final used = inventoryProvider.warehouse?.products
            .fold(0, (sum, p) => sum + p.quantity) ??
        0;
    final percentage = (used / capacity * 100).clamp(0, 100);

    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.primaryContainer,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warehouse Capacity',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
            const SizedBox(height: 8),
            Text('$used of $capacity used',
                style: TextStyle(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditCapacityDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: const Text('Edit Capacity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryAlerts(InventoryProvider inventoryProvider) {
    final expiringProducts = inventoryProvider.warehouse?.products
            .where((p) =>
                p.expiryDate.difference(DateTime.now()).inDays <= 30 &&
                p.expiryDate.isAfter(DateTime.now()))
            .toList() ??
        [];

    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.errorContainer,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expiring Soon',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onErrorContainer)),
            const SizedBox(height: 16),
            if (expiringProducts.isEmpty)
              const Text('No products are expiring soon.')
            else
              Column(
                children: expiringProducts.map((product) {
                  final daysLeft =
                      product.expiryDate.difference(DateTime.now()).inDays;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTips(InventoryProvider inventoryProvider) {
    final tips = [
      'Regularly check expiry dates to minimize waste.',
      'Consider restocking items that are running low.',
      'Organize products by category for easier management.',
      'Monitor sales trends to optimize inventory levels.',
      'Implement a first-in, first-out (FIFO) system for perishables.',
      'Keep track of seasonal products for better sales.',
      'Utilize inventory management software for efficiency.',
    ];

    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.secondaryContainer,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Tips',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSecondaryContainer)),
            const SizedBox(height: 16),
            Column(
              children: tips
                  .map((tip) => ListTile(
                        leading: Icon(Icons.lightbulb,
                            color: scheme.onSecondaryContainer),
                        title: Text(tip),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListTab(InventoryProvider inventoryProvider) {
    final products = inventoryProvider.filteredProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                inventoryProvider.setSearchQuery(value);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonFormField<String>(
            value: _sortOption,
            decoration: const InputDecoration(
              labelText: 'Sort By',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sort),
            ),
            items: const [
              DropdownMenuItem(value: 'Name', child: Text('Name')),
              DropdownMenuItem(value: 'Quantity', child: Text('Quantity')),
              DropdownMenuItem(
                  value: 'Expiry Date', child: Text('Expiry Date')),
            ],
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
                inventoryProvider.setSortOption(_sortOption);
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 2,
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  leading: _buildProductAvatar(product.image),
                  title: Text(product.name),
                  subtitle: Text(
                      '${product.quantity} ${product.unit} · \$${product.price.toStringAsFixed(2)}'),
                  onTap: () => _showProductDetails(context, product),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () =>
                            _showEditProductDialog(context, product, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () =>
                            _confirmDelete(context, inventoryProvider, index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: AddProductForm(),
          ),
        );
      },
    );
  }

  void _showEditCapacityDialog(BuildContext context) {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final currentCapacity = inventoryProvider.warehouse?.capacity ?? 0;
    final TextEditingController capacityController =
        TextEditingController(text: currentCapacity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Edit Inventory Capacity',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter new capacity',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                final int? newCapacity = int.tryParse(capacityController.text);
                if (newCapacity != null &&
                    inventoryProvider.warehouse != null) {
                  inventoryProvider.warehouse!.capacity = newCapacity;
                  inventoryProvider.saveWarehouse();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${product.category}'),
              Text('Quantity: ${product.quantity} ${product.unit}'),
              Text('Price: \$${product.price.toStringAsFixed(2)}'),
              Text(
                  'Expiry Date: ${DateFormat.yMMMMd().format(product.expiryDate)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(
      BuildContext context, Product product, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: EditProductForm(product: product, index: index),
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, InventoryProvider inventoryProvider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                inventoryProvider.deleteProduct(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Analytics Tab as a separate StatefulWidget
class _OptimizedAnalyticsTab extends StatefulWidget {
  final InventoryProvider inventoryProvider;
  final bool showPieChart;
  final ValueChanged<bool> onToggleChart;

  const _OptimizedAnalyticsTab({
    required this.inventoryProvider,
    required this.showPieChart,
    required this.onToggleChart,
  });

  @override
  _OptimizedAnalyticsTabState createState() => _OptimizedAnalyticsTabState();
}

class _OptimizedAnalyticsTabState extends State<_OptimizedAnalyticsTab>
    with AutomaticKeepAliveClientMixin {
  // Cache for expensive computations
  Map<String, double>? _cachedInventoryValueByCategory;
  Map<String, int>? _cachedQuantityByCategory;
  List<Product>? _cachedLowStock;
  List<Product>? _cachedExpiring7Days;
  List<Product>? _cachedTopValuable;
  Map<String, Color>? _cachedCategoryColors;
  double? _cachedTotalValue;
  int? _cachedTotalProducts;
  double? _cachedAvgPrice;

  @override
  bool get wantKeepAlive => true;

  void _computeAnalytics() {
    final products = widget.inventoryProvider.warehouse?.products ?? [];

    if (_cachedInventoryValueByCategory == null) {
      _cachedInventoryValueByCategory =
          widget.inventoryProvider.getInventoryValueByCategory();
      _cachedCategoryColors = _generateCategoryColors(
          _cachedInventoryValueByCategory!.keys.toList());
    }

    if (_cachedQuantityByCategory == null) {
      _cachedQuantityByCategory = {};
      for (final p in products) {
        _cachedQuantityByCategory![p.category] =
            (_cachedQuantityByCategory![p.category] ?? 0) + p.quantity;
      }
    }

    if (_cachedLowStock == null) {
      _cachedLowStock = products.where((p) => p.quantity <= 10).toList()
        ..sort((a, b) => a.quantity.compareTo(b.quantity));
    }

    if (_cachedExpiring7Days == null) {
      _cachedExpiring7Days = products
          .where((p) =>
              p.expiryDate.isAfter(DateTime.now()) &&
              p.expiryDate.difference(DateTime.now()).inDays <= 7)
          .toList();
    }

    if (_cachedTopValuable == null) {
      _cachedTopValuable = [...products]
        ..sort((a, b) => (b.price * b.quantity).compareTo(a.price * a.quantity));
    }

    if (_cachedTotalValue == null) {
      _cachedTotalValue = widget.inventoryProvider.getTotalInventoryValue();
    }

    if (_cachedTotalProducts == null) {
      _cachedTotalProducts = products.length;
    }

    if (_cachedAvgPrice == null) {
      _cachedAvgPrice = _cachedTotalProducts! > 0
          ? _cachedTotalValue! / _cachedTotalProducts!
          : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _computeAnalytics();

    return RefreshIndicator(
      onRefresh: () async {
        // Clear cache on refresh
        _cachedInventoryValueByCategory = null;
        _cachedQuantityByCategory = null;
        _cachedLowStock = null;
        _cachedExpiring7Days = null;
        _cachedTopValuable = null;
        _cachedCategoryColors = null;
        _cachedTotalValue = null;
        _cachedTotalProducts = null;
        _cachedAvgPrice = null;

        await widget.inventoryProvider.loadWarehouse();
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMetricsRow(),
            const SizedBox(height: 24),
            _OptimizedBarChart(
              title: 'Inventory Value by Category',
              data: _cachedInventoryValueByCategory!,
              colors: _cachedCategoryColors!,
              isValueChart: true,
            ),
            const SizedBox(height: 24),
            _OptimizedBarChart(
              title: 'Quantity by Category',
              data: _cachedQuantityByCategory!
                  .map((k, v) => MapEntry(k, v.toDouble())),
              colors: _cachedCategoryColors!,
              isValueChart: false,
            ),
            const SizedBox(height: 24),
            _buildLowStockSection(),
            const SizedBox(height: 24),
            _buildExpiringSection(),
            const SizedBox(height: 24),
            _buildTopValuableSection(),
            const SizedBox(height: 24),
            _buildCategoryDistributionToggle(),
            const SizedBox(height: 16),
            _buildCategoryDistributionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Analytics Dashboard',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        IconButton(
          icon:
              Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            // Clear cache and reload
            _cachedInventoryValueByCategory = null;
            _cachedQuantityByCategory = null;
            _cachedLowStock = null;
            _cachedExpiring7Days = null;
            _cachedTopValuable = null;
            _cachedCategoryColors = null;
            _cachedTotalValue = null;
            _cachedTotalProducts = null;
            _cachedAvgPrice = null;

            widget.inventoryProvider.loadWarehouse();
            setState(() {});
          },
        )
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Total Value',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${_cachedTotalValue!.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnalyticsCard(
            title: 'Avg Price',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${_cachedAvgPrice!.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return _buildAnalyticsCard(
      title: 'Low Stock Items (≤ 10)',
      child: _cachedLowStock!.isEmpty
          ? const Text('No low stock items')
          : Column(
              children: _cachedLowStock!.take(5).map((p) {
                return ListTile(
                  leading: _buildProductAvatar(p.image),
                  title: Text(p.name),
                  subtitle:
                      Text('Qty: ${p.quantity} ${p.unit} · ${p.category}'),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildExpiringSection() {
    return _buildAnalyticsCard(
      title: 'Expiring within 7 days',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_cachedExpiring7Days!.length} product(s)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cachedExpiring7Days!.take(12).map((p) {
              final days = p.expiryDate.difference(DateTime.now()).inDays;
              return Chip(
                label: Text('${p.name} • ${days}d'),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildTopValuableSection() {
    return _buildAnalyticsCard(
      title: 'Top Valuable Products',
      child: Column(
        children: _cachedTopValuable!.take(5).map((p) {
          final value = (p.price * p.quantity);
          return ListTile(
            leading: _buildProductAvatar(p.image),
            title: Text(p.name),
            subtitle: Text(p.category),
            trailing: Text('\$${value.toStringAsFixed(2)}'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDistributionToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Distribution',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        Row(
          children: [
            Text('Bar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            Switch(
              value: widget.showPieChart,
              onChanged: widget.onToggleChart,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            Text('Pie',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
        )
      ],
    );
  }

  Widget _buildCategoryDistributionChart() {
    final screenWidth = MediaQuery.of(context).size.width;

    return _buildAnalyticsCard(
      title: '',
      child: widget.showPieChart
          ? _OptimizedPieChart(
              data: _cachedInventoryValueByCategory!,
              colors: _cachedCategoryColors!,
              screenWidth: screenWidth,
              onSectionTap: (category) {
                final productsUnderCategory = widget
                        .inventoryProvider.warehouse?.products
                        .where((p) => p.category == category)
                        .toList() ??
                    [];
                _showProductsUnderCategoryDialog(
                    context, category, productsUnderCategory);
              },
            )
          : _OptimizedBarChart(
              title: '',
              data: _cachedInventoryValueByCategory!,
              colors: _cachedCategoryColors!,
              isValueChart: true,
            ),
    );
  }

  Widget _buildAnalyticsCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            if (title.isNotEmpty) const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Map<String, Color> _generateCategoryColors(List<String> categories) {
    return {
      'Fruits': Colors.red,
      'Vegetables': Colors.green,
      'Dairy': Colors.blue,
      'Grains': Colors.brown,
      'Meat': Colors.orange,
      'Beverages': Colors.purple,
    };
  }

  Future<void> _showProductsUnderCategoryDialog(
      BuildContext context, String category, List<Product> products) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Products in "$category"'),
          content: SizedBox(
            width: double.maxFinite,
            child: products.isEmpty
                ? const Text('No products found in this category.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Quantity: ${product.quantity} ${product.unit} · \$${product.price.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// Optimized Chart Widgets
class _OptimizedBarChart extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final Map<String, Color> colors;
  final bool isValueChart;

  const _OptimizedBarChart({
    required this.title,
    required this.data,
    required this.colors,
    required this.isValueChart,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title.isEmpty
              ? 'No data available'
              : '$title\nNo data available'),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (title.isNotEmpty) const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final key = data.keys.elementAt(group.x.toInt());
                        return BarTooltipItem(
                          '$key\n',
                          TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: isValueChart
                                  ? '\$${rod.toY.toStringAsFixed(2)}'
                                  : rod.toY.toStringAsFixed(0),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.keys.length) {
                            final category = data.keys.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _abbreviate(category),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            isValueChart
                                ? '\$${value.toInt()}'
                                : value.toInt().toString(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  groupsSpace: 12,
                  maxY: _calculateMaxY(),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _abbreviate(String input) {
    return input.length <= 8 ? input : '${input.substring(0, 6)}..';
  }

  double _calculateMaxY() {
    if (data.isEmpty) return 0.0;
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2);
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final color = colors[entry.key] ?? Colors.teal;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.9),
                color.withValues(alpha: 0.6),
              ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
            width: 24,
          ),
        ],
      );
    }).toList();
  }
}

class _OptimizedPieChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double screenWidth;
  final Function(String) onSectionTap;

  const _OptimizedPieChart({
    required this.data,
    required this.colors,
    required this.screenWidth,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) return;
              if (event is FlTapUpEvent) {
                final touchedIndex =
                    response.touchedSection!.touchedSectionIndex;
                if (touchedIndex < data.keys.length) {
                  final category = data.keys.elementAt(touchedIndex);
                  onSectionTap(category);
                }
              }
            },
          ),
          sections: data.entries.map((entry) {
            final color = colors[entry.key] ?? Colors.teal;
            return PieChartSectionData(
              value: entry.value,
              title: '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
              color: color,
              radius: 80,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Helper: Build product avatar from asset path or file path
Widget _buildProductAvatar(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return const CircleAvatar(
        radius: 20, child: Icon(Icons.inventory_2, size: 20));
  }
  try {
    if (imagePath.startsWith('assets/')) {
      return CircleAvatar(radius: 20, backgroundImage: AssetImage(imagePath));
    }
    if (imagePath.startsWith('/') || imagePath.startsWith('file:')) {
      return CircleAvatar(
          radius: 20,
          backgroundImage:
              FileImage(File(imagePath.replaceFirst('file://', ''))));
    }
    return CircleAvatar(radius: 20, backgroundImage: AssetImage(imagePath));
  } catch (_) {
    return const CircleAvatar(
        radius: 20, child: Icon(Icons.broken_image, size: 20));
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = '';
  int _quantity = 0;
  String _unit = '';
  double _price = 0.0;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  String? _image;

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final categories = inventoryProvider.getCategories();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please enter product name' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList()
              ..add(
                const DropdownMenuItem(
                  value: 'add_new',
                  child: Text('Add New Category'),
                ),
              ),
            onChanged: (value) {
              if (value == 'add_new') {
                _showAddCategoryDialog();
              } else {
                setState(() {
                  _category = value!;
                });
              }
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a category'
                : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => int.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _quantity = int.parse(value!),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value!.isEmpty ? 'Please enter unit' : null,
            onSaved: (value) => _unit = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => double.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _price = double.parse(value!),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expiryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                setState(() {
                  _expiryDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Expiry Date',
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  _image = pickedImage.path;
                });
              }
            },
            child: const Text('Select Product Image'),
          ),
          if (_image != null) ...[
            const SizedBox(height: 10),
            Text('Selected Image: ${_image!.split('/').last}'),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final newProduct = Product(
                  name: _name,
                  category: _category,
                  quantity: _quantity,
                  unit: _unit,
                  price: _price,
                  expiryDate: _expiryDate,
                  image: _image,
                );
                inventoryProvider.addProduct(newProduct);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Category',
              style: TextStyle(color: Colors.black)),
          content: TextField(
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Category Name',
              labelStyle: TextStyle(color: Colors.black),
            ),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  Provider.of<InventoryProvider>(context, listen: false)
                      .addCategory(newCategory);
                  setState(() {
                    _category = newCategory;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class EditProductForm extends StatefulWidget {
  final Product product;
  final int index;

  const EditProductForm(
      {super.key, required this.product, required this.index});

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late int _quantity;
  late String _unit;
  late double _price;
  late DateTime _expiryDate;
  String? _image;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _category = widget.product.category;
    _quantity = widget.product.quantity;
    _unit = widget.product.unit;
    _price = widget.product.price;
    _expiryDate = widget.product.expiryDate;
    _image = widget.product.image;
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final categories = inventoryProvider.getCategories();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(
                labelText: 'Name', border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
                labelText: 'Category', border: OutlineInputBorder()),
            value: _category,
            items: [
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }),
              const DropdownMenuItem<String>(
                value: 'add_new',
                child: Text('Add New Category'),
              ),
            ],
            onChanged: (value) {
              if (value == 'add_new') {
                _showAddCategoryDialog();
              } else {
                setState(() {
                  _category = value!;
                });
              }
            },
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _quantity.toString(),
            decoration: const InputDecoration(
                labelText: 'Quantity', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => int.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _quantity = int.parse(value!),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _unit,
            decoration: const InputDecoration(
                labelText: 'Unit', border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
            onSaved: (value) => _unit = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _price.toString(),
            decoration: const InputDecoration(
                labelText: 'Price', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => double.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _price = double.parse(value!),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expiryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                setState(() {
                  _expiryDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Expiry Date', border: OutlineInputBorder()),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  _image = pickedImage.path;
                });
              }
            },
            child: const Text('Select Product Image'),
          ),
          if (_image != null) ...[
            const SizedBox(height: 10),
            Text('Selected Image: ${_image!.split('/').last}'),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final updatedProduct = Product(
                  name: _name,
                  category: _category,
                  quantity: _quantity,
                  unit: _unit,
                  price: _price,
                  expiryDate: _expiryDate,
                  image: _image,
                );
                inventoryProvider.updateProduct(widget.index, updatedProduct);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Update Product'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Category',
              style: TextStyle(color: Colors.black)),
          content: TextField(
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Category Name',
              labelStyle: TextStyle(color: Colors.black),
            ),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  Provider.of<InventoryProvider>(context, listen: false)
                      .addCategory(newCategory);
                  setState(() {
                    _category = newCategory;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
