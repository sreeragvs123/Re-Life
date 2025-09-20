import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_home.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import 'models/volunteer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');       // session storage
  await Hive.openBox('volunteersBox');
  await Hive.openBox('bloodBox'); // volunteers database

  var box = Hive.box('authBox');
  bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
  String role = box.get('role', defaultValue: "USER");

  Widget startPage;
  if (isLoggedIn && role == "ADMIN") {
    startPage = const AdminHome();
  } else if (isLoggedIn && role == "VOLUNTEER") {
    // restore volunteer info
    final email = box.get('email');
    final vBox = Hive.box('volunteersBox');
    final data = vBox.get(email);
    startPage = VolunteerHome(
  volunteer: Volunteer(
  name: data['name'],
  place: data['place'],
  email: data['email'],
  password: data['password'],
),

    );
  } else {
    startPage = const UserHome();
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: startPage,
  ));
}
