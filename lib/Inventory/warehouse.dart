class Warehouse {
  String name;
  int capacity;
  List<Product> products;

  Warehouse({
    required this.name,
    required this.capacity,
    this.products = const [],
  });
}

class Product {
  String name;
  String category;
  int quantity;
  String unit;
  double price;
  DateTime expiryDate;
  String? image; // Added image property

  Product({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.expiryDate,
    this.image, // Added image parameter
  });
}
