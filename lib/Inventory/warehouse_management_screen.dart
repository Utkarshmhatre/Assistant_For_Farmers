import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_assistx/Inventory/inventory_provider.dart';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:farm_assistx/Inventory/add_product_form.dart' as ext_forms;
import 'package:farm_assistx/Inventory/edit_product_form.dart' as ext_forms;
import 'dart:io';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  _WarehouseManagementScreenState createState() =>
      _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  int _currentIndex = 0;
  String _sortOption = 'Name';
  bool _showPieChartForDistribution = true; // Toggle for distribution view

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadWarehouse();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text('Warehouse Assistant',
                style: Theme.of(context).textTheme.displayMedium),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: cs.primary),
                onPressed: () => inventoryProvider.loadWarehouse(),
              ),
            ],
          ),
          body: inventoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(inventoryProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddProductDialog(context),
            backgroundColor: cs.primary,
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Overview'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Products'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.analytics), label: 'Analytics'),
            ],
            selectedItemColor: cs.primary,
            unselectedItemColor: cs.onSurfaceVariant,
            backgroundColor: cs.surface,
            elevation: 8,
          ),
        );
      },
    );
  }

  Widget _buildBody(InventoryProvider inventoryProvider) {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab(inventoryProvider);
      case 1:
        return _buildProductListTab(inventoryProvider);
      case 2:
        return _buildAnalyticsTab(inventoryProvider);
      default:
        return Container();
    }
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

    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warehouse Capacity',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
            const SizedBox(height: 8),
            Text('$used of $capacity used',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditCapacityDialog(context),
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

    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expiring Soon',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            if (expiringProducts.isEmpty)
              Text('No products are expiring soon.',
                  style: TextStyle(color: cs.onSurfaceVariant))
            else
              Column(
                children: expiringProducts.map((product) {
                  final daysLeft =
                      product.expiryDate.difference(DateTime.now()).inDays;
                  return ListTile(
                    leading: Icon(Icons.timer_outlined, color: cs.tertiary),
                    title: Text(product.name),
                    subtitle: Text(
                        'Expires in $daysLeft day${daysLeft > 1 ? 's' : ''}',
                        style: TextStyle(color: cs.onSurfaceVariant)),
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

    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Tips',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Column(
              children: tips
                  .map((tip) => ListTile(
                        leading: Icon(Icons.lightbulb, color: cs.secondary),
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
              inventoryProvider.setSearchQuery(value);
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
                  leading: _buildProductImage(product.image),
                  title: Text(product.name),
                  subtitle: Text(
                      '${product.quantity} ${product.unit} · \$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  onTap: () => _showProductDetails(context, product),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.teal),
                        onPressed: () =>
                            _showEditProductDialog(context, product, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildProductImage(String? imagePath) {
    final double size = 48;
    if (imagePath == null || imagePath.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.teal.shade50,
        child: const Icon(Icons.inventory_2, color: Colors.teal),
      );
    }
    try {
      if (imagePath.startsWith('asset:')) {
        final assetPath = imagePath.substring(6);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(assetPath,
              width: size, height: size, fit: BoxFit.cover),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                Image.file(file, width: size, height: size, fit: BoxFit.cover),
          );
        }
      }
    } catch (_) {}
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.teal.shade50,
      child: const Icon(Icons.inventory_2, color: Colors.teal),
    );
  }

  Widget _buildAnalyticsTab(InventoryProvider inventoryProvider) {
    final products = inventoryProvider.warehouse?.products ?? [];
    final inventoryValueByCategory =
        inventoryProvider.getInventoryValueByCategory();
    final categoryColors =
        _generateCategoryColors(inventoryValueByCategory.keys.toList());
    final screenWidth = MediaQuery.of(context).size.width;

    // Additional metrics
    double totalValue = inventoryProvider.getTotalInventoryValue();
    int totalProducts = products.length;
    double avgPrice = totalProducts > 0 ? totalValue / totalProducts : 0;
    // Farmer-centric metrics
    final lowStock = products.where((p) => p.quantity <= 10).toList();
    final expiringSoon = inventoryProvider.getExpiringProducts(days: 14);
    final topValueProducts = [...products]
      ..sort((a, b) => (b.price * b.quantity).compareTo(a.price * a.quantity));
    final top3 = topValueProducts.take(3).toList();
    final now = DateTime.now();
    final avgShelfLifeByCategory = <String, double>{};
    final grouped = <String, List<Product>>{};
    for (final p in products) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }
    grouped.forEach((cat, list) {
      if (list.isNotEmpty) {
        final avgDays = list
                .map((p) => p.expiryDate.difference(now).inDays)
                .fold<int>(0, (a, b) => a + b) /
            list.length;
        avgShelfLifeByCategory[cat] = avgDays.toDouble();
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await inventoryProvider.loadWarehouse();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Analytics Dashboard',
                    style: Theme.of(context).textTheme.displayMedium),
                IconButton(
                  icon: Icon(Icons.refresh,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    inventoryProvider.loadWarehouse();
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            // Total Inventory Value card
            _buildAnalyticsCard(
              title: 'Total Inventory Value',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Warehouse Capacity Utilization card
            _buildAnalyticsCard(
              title: 'Warehouse Capacity Utilization',
              child: Column(
                children: [
                  Text(
                    '${inventoryProvider.getCapacityUtilizationPercentage().toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value:
                        inventoryProvider.getCapacityUtilizationPercentage() /
                            100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Average Product Price card
            _buildAnalyticsCard(
              title: 'Average Product Price',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${avgPrice.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Inventory Value by Category - Bar Chart
            _buildAnalyticsCard(
              title: 'Inventory Value by Category',
              child: SizedBox(
                height: screenWidth * 0.8,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(enabled: true),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < inventoryValueByCategory.keys.length) {
                              final category = inventoryValueByCategory.keys
                                  .elementAt(index);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 12),
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
                            return Text('\$${value.toInt()}K',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: inventoryValueByCategory.entries.map((entry) {
                      final index = inventoryValueByCategory.keys
                          .toList()
                          .indexOf(entry.key);
                      final color = categoryColors[entry.key] ??
                          Theme.of(context).colorScheme.primary;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.7)],
                              stops: const [0.1, 1.0],
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            width: screenWidth * 0.06,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Category Distribution (Pie vs. Bar toggle)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category Distribution',
                    style: Theme.of(context).textTheme.displayMedium),
                Row(
                  children: [
                    Text('Bar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                    Switch(
                      value: _showPieChartForDistribution,
                      onChanged: (value) {
                        setState(() {
                          _showPieChartForDistribution = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text('Pie',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsCard(
              title: '',
              child: _showPieChartForDistribution
                  ? SizedBox(
                      height: screenWidth * 0.8,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event,
                                PieTouchResponse? response) {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) return;
                              if (event is FlTapUpEvent) {
                                final touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                                if (touchedIndex <
                                    inventoryValueByCategory.keys.length) {
                                  final category = inventoryValueByCategory.keys
                                      .elementAt(touchedIndex);
                                  final productsUnderCategory =
                                      inventoryProvider.warehouse?.products
                                              .where(
                                                  (p) => p.category == category)
                                              .toList() ??
                                          [];
                                  _showProductsUnderCategoryDialog(
                                      context, category, productsUnderCategory);
                                }
                              }
                            },
                          ),
                          sections:
                              inventoryValueByCategory.entries.map((entry) {
                            final color = categoryColors[entry.key] ??
                                Theme.of(context).colorScheme.primary;
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title:
                                  '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
                              color: color,
                              radius: screenWidth * 0.2,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: screenWidth * 0.8,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(enabled: true),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 &&
                                      index <
                                          inventoryValueByCategory
                                              .keys.length) {
                                    final category = inventoryValueByCategory
                                        .keys
                                        .elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12),
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
                                    '\$${value.toInt()}K',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups:
                              inventoryValueByCategory.entries.map((entry) {
                            final idx = inventoryValueByCategory.keys
                                .toList()
                                .indexOf(entry.key);
                            final color = categoryColors[entry.key] ??
                                Theme.of(context).colorScheme.primary;
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  gradient: LinearGradient(
                                    colors: [color, color.withOpacity(0.7)],
                                    stops: const [0.1, 1.0],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                  width: screenWidth * 0.06,
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            // Total Products Count card
            _buildAnalyticsCard(
              title: 'Total Products Count',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalProducts Products',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Low stock alerts
            _buildAnalyticsCard(
              title: 'Low Stock Alerts (<=10)',
              child: lowStock.isEmpty
                  ? const Text('All good. No low stock items.')
                  : Column(
                      children: lowStock
                          .map((p) => ListTile(
                                leading: _buildProductImage(p.image),
                                title: Text(p.name),
                                subtitle: Text(
                                    'Qty: ${p.quantity} ${p.unit} · ${p.category}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),
            // Expiring soon list
            _buildAnalyticsCard(
              title: 'Expiring in 14 days',
              child: expiringSoon.isEmpty
                  ? const Text('No items expiring soon.')
                  : Column(
                      children: expiringSoon
                          .map((p) => ListTile(
                                leading: const Icon(Icons.warning_amber,
                                    color: Colors.orange),
                                title: Text(p.name),
                                subtitle: Text(
                                    'Expires ${DateFormat.yMMMd().format(p.expiryDate)} · ${p.category}'),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),
            // Top value items
            _buildAnalyticsCard(
              title: 'Top Value Items',
              child: top3.isEmpty
                  ? const Text('No data yet.')
                  : Column(
                      children: top3
                          .map((p) => ListTile(
                                leading: _buildProductImage(p.image),
                                title: Text(p.name),
                                subtitle: Text(p.category),
                                trailing: Text(
                                    '\$${(p.price * p.quantity).toStringAsFixed(2)}'),
                              ))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),
            // Average shelf life by category
            _buildAnalyticsCard(
              title: 'Avg Shelf-life by Category (days)',
              child: avgShelfLifeByCategory.isEmpty
                  ? const Text('No data yet.')
                  : Column(
                      children: avgShelfLifeByCategory.entries
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(e.key,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: LinearProgressIndicator(
                                        value: (e.value / 60).clamp(0, 1),
                                        minHeight: 10,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(e.value.toStringAsFixed(0)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({required String title, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surface,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            if (title.isNotEmpty) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Additional farmer-centric analytics widgets are defined inline in the build.

  Map<String, Color> _generateCategoryColors(List<String> categories) {
    // Generate a color map for categories
    return {
      'Fruits': Colors.red,
      'Vegetables': Colors.green,
      'Dairy': Colors.blue,
      'Grains': Colors.brown,
      'Meat': Colors.orange,
      'Beverages': Colors.purple,
    };
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: ext_forms.AddProductForm(),
          ),
        );
      },
    );
  }

  void _showEditCapacityDialog(BuildContext context) {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final currentCapacity = inventoryProvider.warehouse?.capacity ?? 0;
    final TextEditingController _capacityController =
        TextEditingController(text: currentCapacity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Inventory Capacity',
          ),
          content: TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter new capacity',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? newCapacity = int.tryParse(_capacityController.text);
                if (newCapacity != null &&
                    inventoryProvider.warehouse != null) {
                  inventoryProvider.warehouse!.capacity = newCapacity;
                  inventoryProvider.saveWarehouse();
                  Navigator.pop(context);
                }
              },
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildProductImage(product.image),
              ),
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
            child: ext_forms.EditProductForm(product: product, index: index),
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

// Below are the AddProductForm and EditProductForm widgets (in the same file)

// removed inline form widgets; using external files
