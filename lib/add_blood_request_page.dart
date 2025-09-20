// lib/add_blood_request_page.dart
import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../data/blood_request_data.dart';

class AddBloodRequestPage extends StatefulWidget {
  const AddBloodRequestPage({super.key});

  @override
  State<AddBloodRequestPage> createState() => _AddBloodRequestPageState();
}

class _AddBloodRequestPageState extends State<AddBloodRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();

  void _saveRequest() {
    if (_formKey.currentState!.validate()) {
      final newRequest = BloodRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        bloodGroup: _bloodGroupController.text,
        contact: _contactController.text,
        city: _cityController.text,
      );

      bloodRequests.add(newRequest);
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (val) => val!.isEmpty ? "Enter $label" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Blood Request"), backgroundColor: Colors.red.shade700),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Name", _nameController),
              _buildTextField("Blood Group", _bloodGroupController),
              _buildTextField("Contact Number", _contactController),
              _buildTextField("City", _cityController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRequest,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
