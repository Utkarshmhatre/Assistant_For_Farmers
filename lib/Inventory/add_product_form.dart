import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_assistx/Inventory/inventory_provider.dart';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
    final categories = inventoryProvider.getCategories(); // Get categories from provider
    final products = inventoryProvider.getProducts(); // Get products from provider

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder(), labelStyle: TextStyle(color: Colors.white)),
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
                  child: Text(category, style: const TextStyle(color: Colors.white)),
                );
              }),
              const DropdownMenuItem<String>(
                value: 'add_new',
                child: Text('Add New Category', style: TextStyle(color: Colors.white)),
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
            validator: (value) => value == null ? 'Please select a category' : null,
            dropdownColor: Colors.black,
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder(), labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            validator: (value) => int.tryParse(value!) == null ? 'Please enter a valid number' : null,
            onSaved: (value) => _quantity = int.parse(value!),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), labelStyle: TextStyle(color: Colors.white)),
            validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
            onSaved: (value) => _unit = value!,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), labelStyle: TextStyle(color: Colors.white)),
            keyboardType: TextInputType.number,
            validator: (value) => double.tryParse(value!) == null ? 'Please enter a valid number' : null,
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
                  _expiryDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Expiry Date', border: OutlineInputBorder(), labelStyle: TextStyle(color: Colors.white)),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate), style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
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
            ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: Image.file(
                  File(_image!),
                  fit: BoxFit.cover,
                ),
              ),
              title: const Text('Product Image', style: TextStyle(color: Colors.black)),
            ),
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
          title: const Text('Add New Category', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Category Name',
              labelStyle: TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  Provider.of<InventoryProvider>(context, listen: false).addCategory(newCategory);
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