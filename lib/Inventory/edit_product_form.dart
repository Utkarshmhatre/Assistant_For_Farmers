import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farm_assistx/Inventory/inventory_provider.dart';
import 'package:farm_assistx/Inventory/warehouse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProductForm extends StatefulWidget {
  final Product product;
  final int index;

  const EditProductForm({super.key, required this.product, required this.index});

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
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            onSaved: (value) => _name = value!,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
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
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _quantity.toString(),
            decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => int.tryParse(value!) == null ? 'Please enter a valid number' : null,
            onSaved: (value) => _quantity = int.parse(value!),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _unit,
            decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
            validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
            onSaved: (value) => _unit = value!,
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _price.toString(),
            decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => double.tryParse(value!) == null ? 'Please enter a valid number' : null,
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
              decoration: const InputDecoration(labelText: 'Expiry Date', border: OutlineInputBorder()),
              child: Text(DateFormat('yyyy-MM-dd').format(_expiryDate)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
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
          title: const Text('Add New Category'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Category Name'),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
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