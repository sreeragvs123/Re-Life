// lib/add_blood_request_page.dart
// lib/add_blood_request_page.dart
import 'package:flutter/material.dart';
import '../models/blood_request.dart';
import '../data/blood_request_data.dart';
import '../utils/validators.dart';

class AddBloodRequestPage extends StatefulWidget {
  const AddBloodRequestPage({super.key});

  @override
  State<AddBloodRequestPage> createState() => _AddBloodRequestPageState();
}

class _AddBloodRequestPageState extends State<AddBloodRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  void _saveRequest() {
    if (_formKey.currentState!.validate()) {
      final newRequest = BloodRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        contact: _contactController.text.trim(),
        city: _cityController.text.trim(),
      );

      bloodRequests.add(newRequest);
      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String type,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => Validators.validate(value: val ?? '', type: type),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBloodGroup,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        items: _bloodGroups
            .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
            .toList(),
        decoration: InputDecoration(
          labelText: "Blood Group",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (val) => val == null || val.isEmpty ? "Select Blood Group" : null,
        onChanged: (val) => setState(() => _selectedBloodGroup = val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Blood Request"),
        backgroundColor: Colors.red.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(label: "Name", controller: _nameController, type: "name"),
              _buildBloodGroupDropdown(),
              _buildTextField(
                label: "Contact Number",
                controller: _contactController,
                type: "mobile",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(label: "City", controller: _cityController, type: "place"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}