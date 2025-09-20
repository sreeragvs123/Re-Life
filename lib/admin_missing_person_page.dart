import 'package:flutter/material.dart';
import '../models/missing_person.dart';

class AdminMissingPersonPage extends StatefulWidget {
  final List<MissingPerson> persons;
  const AdminMissingPersonPage({super.key, required this.persons});

  @override
  State<AdminMissingPersonPage> createState() =>
      _AdminMissingPersonPageState();
}

class _AdminMissingPersonPageState extends State<AdminMissingPersonPage> {
  late List<MissingPerson> _persons;

  @override
  void initState() {
    super.initState();
    _persons = widget.persons;
  }

  void _markAsFound(String id) {
    setState(() {
      _persons.removeWhere((p) => p.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Marked as Found ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Missing Persons",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _persons.isEmpty
            ? const Center(
                child: Text(
                  "🎉 No Missing Persons Reported!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _persons.length,
                itemBuilder: (context, index) {
                  final person = _persons[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          person.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        person.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Age: ${person.age}"),
                            Text("Last Seen: ${person.lastSeen}"),
                            Text("Family: ${person.familyName}"),
                            Text("Contact: ${person.familyContact}"),
                          ],
                        ),
                      ),
                      trailing: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _markAsFound(person.id),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text("Found"),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
