import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product_request.dart';

class AddProductPage extends StatefulWidget {
  final String requesterName; // Pass Admin or Volunteer name

  const AddProductPage({super.key, required this.requesterName});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String selectedUrgency = "Medium";

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product Request"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Product Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Urgency Dropdown
            DropdownButtonFormField<String>(
              value: selectedUrgency,
              decoration: const InputDecoration(
                labelText: "Urgency",
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: ["High", "Medium", "Low"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedUrgency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  // Add to global list
                  productRequests.add(ProductRequest(
                    name: nameController.text,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    requester: widget.requesterName,
                    urgency: selectedUrgency,
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Product request added!")),
                  );

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
