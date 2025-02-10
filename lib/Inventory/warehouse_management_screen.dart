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
            child: Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 90
                    ? Colors.red
                    : (percentage > 70 ? Colors.orange : Colors.teal),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$used / $capacity units used (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showEditCapacityDialog(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Edit Capacity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryAlerts(InventoryProvider inventoryProvider) {
    final expiringProducts = inventoryProvider.warehouse?.products
            .where((p) => p.expiryDate.difference(DateTime.now()).inDays <= 30)
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
            const Text('Expiry Alerts',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 16),
            if (expiringProducts.isEmpty)
              const Text('No products expiring soon.')
            else
              Column(
                children: expiringProducts.map((product) {
                  final daysUntilExpiry =
                      product.expiryDate.difference(DateTime.now()).inDays;
                  return ListTile(
                    title: Text(product.name,
                        style: const TextStyle(color: Colors.black)),
                    subtitle: Text('Expires in $daysUntilExpiry days',
                        style: const TextStyle(color: Colors.red)),
                    leading: const Icon(Icons.warning, color: Colors.orange),
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
                    color: Colors.teal)),
            const SizedBox(height: 16),
            for (var tip in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.yellow),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
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
            decoration: InputDecoration(
              labelText: 'Search Products',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                inventoryProvider.setSearchQuery(_searchQuery);
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
              labelStyle: TextStyle(color: Colors.white),
            ),
            dropdownColor: Colors.black,
            items: ['Name', 'Quantity', 'Expiry Date'].map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child:
                    Text(option, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: Colors.lightBlue[100],
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ListTile(
                    leading: product.image != null
                        ? SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.file(
                              File(product.image!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                    title: Text(
                      product.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      '${product.quantity} ${product.unit}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditProductDialog(context, product, index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(context, inventoryProvider, index);
                          },
                        ),
                      ],
                    ),
                    onTap: () => _showProductDetails(context, product),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsCard(
            title: 'Inventory Value by Category',
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(enabled: true),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            inventoryValueByCategory.keys
                                .elementAt(value.toInt()),
                            style: const TextStyle(
                                color: Colors.teal, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          '₹${value.toInt()}K',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: inventoryValueByCategory.entries.map((entry) {
                    final color = categoryColors[entry.key] ?? Colors.teal;
                    return BarChartGroupData(
                      x: inventoryValueByCategory.keys
                          .toList()
                          .indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            stops: const [0.1, 1.0],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          width: 22,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            color: Colors.grey[200],
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
          _buildAnalyticsCard(
            title: 'Category Distribution',
            child: SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (response != null && response.touchedSection != null) {
                        final touchedSection = response.touchedSection!;
                        final category = inventoryValueByCategory.keys
                            .elementAt(touchedSection.touchedSectionIndex);
                        final value = inventoryValueByCategory[category];
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$category: ₹$value')));
                      }
                    },
                  ),
                  sections: inventoryValueByCategory.entries.map((entry) {
                    final color = categoryColors[entry.key] ?? Colors.teal;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n₹${entry.value}',
                      color: color,
                      radius: 100,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      badgeWidget: CircleAvatar(
                        backgroundColor: color,
                        child: Text('${entry.value}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      badgePositionPercentageOffset: 1.5,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAnalyticsCard(
            title: 'Inventory Trends',
            child: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(color: Colors.teal)),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                            '₹${value.toInt()}K',
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: Colors.teal)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateTrendData(products),
                      isCurved: true,
                      color: Colors.teal,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.teal.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildAnalyticsCard(
            title: 'Category Comparison',
            child: SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: _generateCategoryComparisonData(
                          inventoryValueByCategory),
                      fillColor: Colors.teal.withOpacity(0.3),
                      borderColor: Colors.teal,
                      borderWidth: 2,
                      entryRadius: 3,
                    ),
                  ],
                  titlePositionPercentageOffset: 0.2,
                  radarBorderData: const BorderSide(color: Colors.teal),
                  radarShape: RadarShape.circle,
                  tickCount: 5,
                  tickBorderData: const BorderSide(color: Colors.grey),
                  ticksTextStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({required String title, required Widget child}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.pink[100],
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal)),
            const SizedBox(height: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${product.category}'),
              Text('Quantity: ${product.quantity} ${product.unit}'),
              Text('Price: ₹${product.price.toStringAsFixed(2)}'),
              Text(
                  'Expiry Date: ${DateFormat('yyyy-MM-dd').format(product.expiryDate)}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
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
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                inventoryProvider.deleteProduct(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
  String? _image; // Variable to hold the selected image path

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final categories =
        inventoryProvider.getCategories(); // Get categories from provider
    final products =
        inventoryProvider.getProducts(); // Get products from provider

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white)),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            onSaved: (value) => _name = value!,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.white),
            ),
            value: _category.isNotEmpty ? _category : null,
            items: [
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category,
                      style: const TextStyle(color: Colors.white)),
                );
              }),
              const DropdownMenuItem<String>(
                value: 'add_new',
                child: Text('Add New Category',
                    style: TextStyle(color: Colors.white)),
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
            dropdownColor: Colors.black,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            validator: (value) => int.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _quantity = int.parse(value!),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white)),
            validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
            onSaved: (value) => _unit = value!,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            validator: (value) => double.tryParse(value!) == null
                ? 'Please enter a valid number'
                : null,
            onSaved: (value) => _price = double.parse(value!),
            style: const TextStyle(color: Colors.white),
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
                  _expiryDate = picked; // Store the image path as a string
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white)),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate),
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() {
                  _image = pickedImage.path; // Store the image path as a string
                });
              }
            },
            child: const Text('Select Product Image'),
          ),
          if (_image != null) ...[
            const SizedBox(height: 10),
            Text(
                'Selected Image: ${_image!.split('/').last}'), // Display the image name
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
                  image: _image, // Save the image path
                );
                inventoryProvider.addProduct(newProduct);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('Add Product'),
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
          // ...similar fields as AddProductForm...
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
            child: Text('Update Product'),
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
