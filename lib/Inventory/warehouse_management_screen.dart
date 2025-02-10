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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  String _searchQuery = '';
  String _sortOption = 'Name';
  bool _showPieChartForDistribution = true; // Toggle for distribution view
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadWarehouse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Warehouse Asistant'),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => inventoryProvider.loadWarehouse(),
              ),
            ],
          ),
          body: inventoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(inventoryProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddProductDialog(context),
            backgroundColor: Colors.teal,
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
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
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

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.lightGreen[100],
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Warehouse Capacity',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
            const SizedBox(height: 8),
            Text('$used of $capacity used',
                style: const TextStyle(color: Colors.teal)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showEditCapacityDialog(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
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

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.orange[100],
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expiring Soon',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
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

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.yellow[100],
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Tips',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            const SizedBox(height: 16),
            Column(
              children: tips
                  .map((tip) => ListTile(
                        leading:
                            const Icon(Icons.lightbulb, color: Colors.brown),
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
                _searchQuery = value;
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
                  title: Text(product.name),
                  subtitle: Text(
                      '${product.quantity} ${product.unit} · \$${product.price.toStringAsFixed(2)}'),
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
                const Text(
                  'Analytics Dashboard',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.teal),
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
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.teal,
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${avgPrice.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.blue,
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
                                  style: const TextStyle(
                                      color: Colors.teal, fontSize: 12),
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
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: inventoryValueByCategory.entries.map((entry) {
                      final index = inventoryValueByCategory.keys
                          .toList()
                          .indexOf(entry.key);
                      final color = categoryColors[entry.key] ?? Colors.teal;
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
                              color: Colors.grey[200]!,
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
                const Text(
                  'Category Distribution',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                Row(
                  children: [
                    const Text('Bar', style: TextStyle(color: Colors.teal)),
                    Switch(
                      value: _showPieChartForDistribution,
                      onChanged: (value) {
                        setState(() {
                          _showPieChartForDistribution = value;
                        });
                      },
                      activeColor: Colors.teal,
                    ),
                    const Text('Pie', style: TextStyle(color: Colors.teal)),
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
                            final color =
                                categoryColors[entry.key] ?? Colors.teal;
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
                                        style: const TextStyle(
                                            color: Colors.teal, fontSize: 12),
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
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 10),
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
                            final color =
                                categoryColors[entry.key] ?? Colors.teal;
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
                                    color: Colors.grey[200]!,
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalProducts Products',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({required String title, required Widget child}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            if (title.isNotEmpty) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateTrendData(List<Product> products) {
    // Mock data for trends, replace with actual data as needed
    return [
      const FlSpot(0, 50),
      const FlSpot(1, 80),
      const FlSpot(2, 70),
      const FlSpot(3, 90),
      const FlSpot(4, 100),
    ];
  }

  List<RadarEntry> _generateCategoryComparisonData(
      Map<String, double> inventoryValueByCategory) {
    // Ensure at least three entries for the radar chart
    List<RadarEntry> entries = inventoryValueByCategory.entries.map((entry) {
      return RadarEntry(value: entry.value);
    }).toList();

    // Add dummy entries if less than three
    while (entries.length < 3) {
      entries.add(const RadarEntry(value: 0)); // Add a zero entry
    }

    return entries;
  }

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
    final TextEditingController _capacityController =
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
            controller: _capacityController,
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
                final int? newCapacity = int.tryParse(_capacityController.text);
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
  String? _image; // Variable to hold the selected image path

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
          backgroundColor: Colors.white, // Light background for dark text
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
