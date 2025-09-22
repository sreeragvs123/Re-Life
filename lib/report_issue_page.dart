import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'data/issue_data.dart';
import 'models/issue_model.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String name = "";
  String email = "";
  String? phone;
  String title = "";
  String description = "";
  String? category;
  String? priority;
  String? location;
  Uint8List? attachment;

  final List<String> categories = ["Bug", "Feature Request", "UI Issue", "Other"];
  final List<String> priorities = ["Low", "Medium", "High", "Urgent"];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg','png','mp4','mov'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        attachment = result.files.single.bytes;
      });
    }
  }

Future<void> captureFromCamera() async {
  if (kIsWeb) {
    // Web: pick image from files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        attachment = result.files.single.bytes;
      });
    }
  } else {
    // Mobile: use camera
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        attachment = bytes;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report an Issue"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Header info card
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem, color: Colors.blue, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Please provide all details clearly so we can resolve the issue faster.",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Form card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
                        onSaved: (v) => name = v!,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Enter email" : null,
                        onSaved: (v) => email = v!,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Phone (optional)",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => phone = v,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Title",
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Enter title" : null,
                        onSaved: (v) => title = v!,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty ? "Enter description" : null,
                        onSaved: (v) => description = v!,
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => category = v),
                        onSaved: (v) => category = v,
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: const InputDecoration(
                          labelText: "Priority",
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: priorities
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setState(() => priority = v),
                        onSaved: (v) => priority = v,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location (optional)",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (v) => location = v,
                      ),
                      const SizedBox(height: 20),

                      // ✅ Attachment buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Attach File"),
                            onPressed: pickFile,
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Capture"),
                            onPressed: captureFromCamera,
                          ),
                        ],
                      ),
                      if (attachment != null) const SizedBox(height: 10),
                      if (attachment != null)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              attachment!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 25),

                      // ✅ Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              issues.add(Issue(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                email: email,
                                phone: phone,
                                title: title,
                                description: description,
                                category: category,
                                priority: priority,
                                location: location,
                                attachment: attachment,
                                date: DateTime.now(),
                              ));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Issue reported successfully")),
                              );

                              Navigator.pop(context, true);
                            }
                          },
                          icon: const Icon(Icons.send),
                          label: const Text(
                            "Submit Issue",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
