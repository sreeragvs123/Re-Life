import '../models/volunteer.dart'; // adjust path if model is in models folder

// Sample volunteers with email and password
List<Volunteer> volunteers = [
  Volunteer(
      name: 'Amit Sharma',
      place: 'Delhi',
      email: 'amit.sharma@example.com',
      password: '123456'),
  Volunteer(
      name: 'Priya Singh',
      place: 'Mumbai',
      email: 'priya.singh@example.com',
      password: '123456'),
  Volunteer(
      name: 'Rahul Verma',
      place: 'Delhi',
      email: 'rahul.verma@example.com',
      password: '123456'),
  Volunteer(
      name: 'Sneha Kapoor',
      place: 'Bangalore',
      email: 'sneha.kapoor@example.com',
      password: '123456'),
  Volunteer(
      name: 'Ankit Jain',
      place: 'Mumbai',
      email: 'ankit.jain@example.com',
      password: '123456'),
  Volunteer(
      name: 'Riya Mehra',
      place: 'Bangalore',
      email: 'riya.mehra@example.com',
      password: '123456'),
];

// Tasks assigned to each place (grouped)
Map<String, List<String>> groupTasks = {
  'Delhi': [
    'Distribute food packets',
    'Check local shelters',
    'Assist at railway station',
  ],
  'Mumbai': [
    'Provide first aid',
    'Help at evacuation center',
    'Coordinate transport',
  ],
  'Bangalore': [
    'Manage donation drives',
    'Assist flood victims',
    'Set up temporary shelters',
  ],
};
