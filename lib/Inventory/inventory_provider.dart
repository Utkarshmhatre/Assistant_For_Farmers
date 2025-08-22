import 'package:flutter/foundation.dart';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:farm_assistx/Inventory/database_helper.dart';

class InventoryProvider with ChangeNotifier {
  Warehouse? _warehouse;
  bool _isLoading = false;
  List<String> _categories = []; // List to store categories

  // New variables for search and sort
  String _searchQuery = '';
  String _sortOption = 'Name';

  Warehouse? get warehouse => _warehouse;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories; // Getter for categories

  // Getter for filtered and sorted products
  List<Product> get filteredProducts {
    if (_warehouse == null) return [];

    // Make a local copy of products
    List<Product> products = _warehouse!.products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'Name':
        products.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Quantity':
        products.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Expiry Date':
        products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      default:
        // No sorting
        break;
    }

    return products;
  }

  // Methods to set search query and sort option
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  Future<void> loadWarehouse() async {
    _isLoading = true;
    notifyListeners();

    try {
      _warehouse = await DatabaseHelper.instance.getWarehouse();
      if (_warehouse == null) {
        _warehouse =
            Warehouse(name: "Farm Warehouse", capacity: 1000, products: []);
        // Seed sample produce
        _warehouse!.products.addAll(_sampleProducts());
        await DatabaseHelper.instance.saveWarehouse(_warehouse!);
      }
      // If warehouse exists but empty, seed once for better UX
      if (_warehouse!.products.isEmpty) {
        _warehouse!.products.addAll(_sampleProducts());
        await DatabaseHelper.instance.saveWarehouse(_warehouse!);
      }
      _categories = _warehouse!.products
          .map((product) => product.category)
          .toSet()
          .toList(); // Load categories from products
    } catch (e) {
      print('Error loading warehouse: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Product> _sampleProducts() {
    final now = DateTime.now();
    return [
      Product(
          name: 'Tomato',
          category: 'Vegetables',
          quantity: 35,
          unit: 'kg',
          price: 1.2,
          expiryDate: now.add(const Duration(days: 7)),
          image: 'asset:assets/images/Illustration-Red.png'),
      Product(
          name: 'Potato',
          category: 'Vegetables',
          quantity: 80,
          unit: 'kg',
          price: 0.8,
          expiryDate: now.add(const Duration(days: 25)),
          image: 'asset:assets/images/Illustration-Yellow.png'),
      Product(
          name: 'Onion',
          category: 'Vegetables',
          quantity: 50,
          unit: 'kg',
          price: 0.9,
          expiryDate: now.add(const Duration(days: 20)),
          image: 'asset:assets/images/Illustration-Blue.png'),
      Product(
          name: 'Apple',
          category: 'Fruits',
          quantity: 40,
          unit: 'kg',
          price: 2.5,
          expiryDate: now.add(const Duration(days: 15)),
          image: 'asset:assets/images/Slider-Red.png'),
      Product(
          name: 'Banana',
          category: 'Fruits',
          quantity: 60,
          unit: 'kg',
          price: 1.1,
          expiryDate: now.add(const Duration(days: 5)),
          image: 'asset:assets/images/Slider-Yellow.png'),
      Product(
          name: 'Milk',
          category: 'Dairy',
          quantity: 25,
          unit: 'L',
          price: 0.6,
          expiryDate: now.add(const Duration(days: 6)),
          image: 'asset:assets/images/Bg-Blue.png'),
      Product(
          name: 'Rice',
          category: 'Grains',
          quantity: 120,
          unit: 'kg',
          price: 0.5,
          expiryDate: now.add(const Duration(days: 180)),
          image: 'asset:assets/images/Bg-Yellow.png'),
    ];
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
      saveWarehouse();
    }
  }

  Future<void> addProduct(Product product) async {
    final existingProductIndex = _warehouse!.products
        .indexWhere((p) => p.name.toLowerCase() == product.name.toLowerCase());
    if (existingProductIndex != -1) {
      // Update existing product quantity
      _warehouse!.products[existingProductIndex].quantity += product.quantity;
    } else {
      _warehouse!.products.add(product);
    }
    // Add category if it doesn't exist
    if (!_categories.contains(product.category)) {
      _categories.add(product.category);
    }
    await DatabaseHelper.instance.saveWarehouse(_warehouse!);
    notifyListeners();
  }

  Future<void> updateProduct(int index, Product product) async {
    await DatabaseHelper.instance.updateProduct(index, product);
    await loadWarehouse();
  }

  Future<void> deleteProduct(int index) async {
    await DatabaseHelper.instance.deleteProduct(index);
    await loadWarehouse();
  }

  List<Product> getExpiringProducts({int days = 30}) {
    if (_warehouse == null) return [];
    final now = DateTime.now();
    return _warehouse!.products
        .where((p) => p.expiryDate.difference(now).inDays <= days)
        .toList();
  }

  Map<String, double> getInventoryValueByCategory() {
    if (_warehouse == null) return {};
    final valueByCategory = <String, double>{};
    for (var product in _warehouse!.products) {
      valueByCategory[product.category] =
          (valueByCategory[product.category] ?? 0) +
              (product.price * product.quantity);
    }
    return valueByCategory;
  }

  double getTotalInventoryValue() {
    if (_warehouse == null) return 0;
    return _warehouse!.products
        .fold(0, (sum, product) => sum + (product.price * product.quantity));
  }

  int getUsedCapacity() {
    if (_warehouse == null) return 0;
    return _warehouse!.products
        .fold(0, (sum, product) => sum + product.quantity);
  }

  double getCapacityUtilizationPercentage() {
    if (_warehouse == null || _warehouse!.capacity == 0) return 0;
    return (getUsedCapacity() / _warehouse!.capacity) * 100;
  }

  List<String> getCategories() {
    return _categories; // Return the list of categories
  }

  List<Product> getProducts() {
    return _warehouse?.products ?? []; // Return the list of products
  }

  Future<void> saveWarehouse() async {
    if (_warehouse != null) {
      await DatabaseHelper.instance.saveWarehouse(_warehouse!);
    }
  }
}
