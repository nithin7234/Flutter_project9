import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UpdateProductScreen(),
  ));
}
class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key});
  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}
class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _statusMessage = "";
  String? _docId;
  Future<void> _searchProduct() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _statusMessage = "Please enter a product name.";
        _docId = null;
      });
      return;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: name)
        .get();
    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _statusMessage = "Product not found.";
        _docId = null;
        _quantityController.clear();
        _priceController.clear();
      });
    } else {
      final product = querySnapshot.docs.first;
      setState(() {
        _docId = product.id;
        _quantityController.text = product['quantity'].toString();
        _priceController.text = product['price'].toString();
        _statusMessage = "Product loaded successfully.";
      });
    }
  }
  Future<void> _updateProduct() async {
    if (_docId == null) {
      setState(() {
        _statusMessage = "Please search a product first.";
      });
      return;
    }
    final newQuantity = int.tryParse(_quantityController.text.trim());
    final newPrice = double.tryParse(_priceController.text.trim());

    if (newQuantity == null || newPrice == null) {
      setState(() {
        _statusMessage = "Please enter valid quantity and price.";
      });
      return;
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(_docId)
        .update({
      'quantity': newQuantity,
      'price': newPrice,
    });

    setState(() {
      _statusMessage = "Product updated successfully!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Product Details"),
        backgroundColor: const Color.fromARGB(255, 187, 0, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Enter product name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _searchProduct,
                child: const Text("Search"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price (₹)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Update"),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.contains("not") ||
                            _statusMessage.contains("Please")
                        ? Colors.red
                        : Colors.green,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

