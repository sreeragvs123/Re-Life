import '../models/donation.dart';

List<Donation> donationsList = [
  Donation(
    id: '1',
    
    donorName: 'Alice',
    contact: 'alice@example.com',
    address: '123 Main St',
    item: 'Blankets',
    quantity: 10,
    date: DateTime.now().subtract(const Duration(days: 2)),
    isApproved: true,
    status: 'Delivered',
  ),
  Donation(
    id: '2',
    
    donorName: 'Bob',
    contact: 'bob@example.com',
    address: '456 Park Ave',
    item: 'Water Bottles',
    quantity: 50,
    date: DateTime.now().subtract(const Duration(days: 1)),
    isApproved: true,
    status: 'On the way',
  ),
  Donation(
    id: '3',
    
    donorName: 'Charlie',
    contact: 'charlie@example.com',
    address: '789 Elm St',
    item: 'Canned Food',
    quantity: 20,
    date: DateTime.now().subtract(const Duration(days: 3)),
    isApproved: false,
    status: 'Pending',
  ),
  Donation(
    id: '4',
   
    donorName: 'Diana',
    contact: 'diana@example.com',
    address: '101 Maple Rd',
    item: 'Masks',
    quantity: 100,
    date: DateTime.now().subtract(const Duration(hours: 12)),
    isApproved: true,
    status: 'Approved',
  ),
  Donation(
    id: '5',
   
    donorName: 'Ethan',
    contact: 'ethan@example.com',
    address: '202 Oak Ln',
    item: 'Gloves',
    quantity: 200,
    date: DateTime.now(),
    isApproved: false,
    status: 'Pending',
  ),
];
