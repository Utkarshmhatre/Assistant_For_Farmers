import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'warehouse.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static SharedPreferences? _prefs;

  DatabaseHelper._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveWarehouse(Warehouse warehouse) async {
    try {
      final pref = await prefs;
      final warehouseJson = json.encode({
        'name': warehouse.name,
        'capacity': warehouse.capacity,
        'products': warehouse.products.map((p) => {
          'name': p.name,
          'category': p.category,
          'quantity': p.quantity,
          'unit': p.unit,
          'price': p.price,
          'expiryDate': p.expiryDate.toIso8601String(),
          'image': p.image, // Include image if present
        }).toList(),
      });
      await pref.setString('warehouse', warehouseJson);
      print("Saved warehouse: ${warehouse.name}, Products: ${warehouse.products.length}");
    } catch (e) {
      print("Error saving warehouse: $e");
    }
  }

  Future<Warehouse?> getWarehouse() async {
    try {
      final pref = await prefs;
      final warehouseJson = pref.getString('warehouse');
      if (warehouseJson == null) {
        print("No warehouse data found");
        return null;
      }

      final warehouseMap = json.decode(warehouseJson) as Map<String, dynamic>;
      final warehouse = Warehouse(
        name: warehouseMap['name'],
        capacity: warehouseMap['capacity'],
        products: (warehouseMap['products'] as List).map((p) => Product(
          name: p['name'],
          category: p['category'],
          quantity: p['quantity'],
          unit: p['unit'],
          price: p['price'],
          expiryDate: DateTime.parse(p['expiryDate']),
          image: p['image'], // Load image if present
        )).toList(),
      );
      print("Retrieved warehouse: ${warehouse.name}, Products: ${warehouse.products.length}");
      return warehouse;
    } catch (e) {
      print("Error retrieving warehouse: $e");
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final warehouse = await getWarehouse();
      if (warehouse != null) {
        warehouse.products.add(product);
        await saveWarehouse(warehouse);
        print("Added product: ${product.name}");
      } else {
        print("Failed to add product: Warehouse is null");
        // Initialize a new warehouse if it doesn't exist
        final newWarehouse = Warehouse(name: "Farm Warehouse", capacity: 1000, products: [product]);
        await saveWarehouse(newWarehouse);
        print("Created new warehouse and added product: ${product.name}");
      }
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  Future<void> updateProduct(int index, Product product) async {
    try {
      final warehouse = await getWarehouse();
      if (warehouse != null && index >= 0 && index < warehouse.products.length) {
        warehouse.products[index] = product;
        await saveWarehouse(warehouse);
        print("Updated product at index $index: ${product.name}");
      } else {
        print("Failed to update product: Invalid index or warehouse is null");
      }
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  Future<void> deleteProduct(int index) async {
    try {
      final warehouse = await getWarehouse();
      if (warehouse != null && index >= 0 && index < warehouse.products.length) {
        final deletedProduct = warehouse.products.removeAt(index);
        await saveWarehouse(warehouse);
        print("Deleted product at index $index: ${deletedProduct.name}");
      } else {
        print("Failed to delete product: Invalid index or warehouse is null");
      }
    } catch (e) {
      print("Error deleting product: $e");
    }
  }
}

