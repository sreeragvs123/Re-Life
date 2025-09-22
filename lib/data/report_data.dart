import '../models/report_model.dart';
import 'volunteer_data.dart'; // ✅ reuse groupTasks

// Sample reports
List<Report> reports = [
  Report(
    id: 'R1',
    volunteerName: 'Amit Sharma',
    group: 'Delhi',
    task: 'Distribute food packets',
    description: 'Distributed 50 food packets in sector 5.',
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Report(
    id: 'R2',
    volunteerName: 'Priya Singh',
    group: 'Mumbai',
    task: 'Help at evacuation center',
    description: 'Assisted 20 families at the evacuation center.',
    date: DateTime.now(),
  ),
  Report(
    id: 'R3',
    volunteerName: 'Riya Mehra',
    group: 'Bangalore',
    task: 'Assist flood victims',
    description: 'Helped 10 flood-affected families with shelter.',
    date: DateTime.now(),
  ),
];
