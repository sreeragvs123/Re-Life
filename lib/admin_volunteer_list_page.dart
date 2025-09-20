import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'admin_assign_task_page.dart';
import 'data/volunteer_data.dart'; // still needed for groupTasks

class AdminVolunteerListPage extends StatelessWidget {
  const AdminVolunteerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Groups"),
        backgroundColor: Colors.teal,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('volunteersBox').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No volunteers yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Group volunteers by place
          final Map<String, List<Map>> grouped = {};
          for (var v in box.values) {
            final place = v['place'] as String;
            grouped.putIfAbsent(place, () => []);
            grouped[place]!.add(v as Map);
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: grouped.entries.map((entry) {
              final place = entry.key;
              final volunteers = entry.value;
              final assignedTasks = groupTasks[place] ?? [];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.teal.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      place[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    "Group: $place",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    // Volunteers shown as chips
                    Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: volunteers
                          .map(
                            (v) => Chip(
                              avatar: const Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(v['name']),
                              backgroundColor: Colors.teal.shade200,
                              labelStyle:
                                  const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),

                    if (assignedTasks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "Assigned Tasks:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children: assignedTasks
                            .map(
                              (task) => Card(
                                color: Colors.orange.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.task_alt,
                                    color: Colors.orange,
                                  ),
                                  title: Text(task),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Assign Task button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminAssignTaskPage(place: place),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_task),
                      label: const Text(
                        "Assign Task",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
