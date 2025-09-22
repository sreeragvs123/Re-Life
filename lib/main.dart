import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_home.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import 'models/volunteer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open required boxes
  await Hive.openBox('authBox');       // session storage
  await Hive.openBox('volunteersBox'); // volunteers database
  await Hive.openBox('bloodBox');      // blood donation db (if needed)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Disaster Management App",
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 3 seconds before moving ahead
    Future.delayed(const Duration(seconds: 3), () {
      _navigateNext();
    });
  }

  void _navigateNext() {
    var authBox = Hive.box('authBox');
    bool isLoggedIn = authBox.get('isLoggedIn', defaultValue: false);
    String role = authBox.get('role', defaultValue: "USER");

    Widget nextPage;
    if (isLoggedIn && role == "ADMIN") {
      nextPage = const AdminHome();
    } else if (isLoggedIn && role == "VOLUNTEER") {
      final email = authBox.get('email');
      final vBox = Hive.box('volunteersBox');
      final data = vBox.get(email);

      nextPage = VolunteerHome(
        volunteer: Volunteer(
          name: data['name'],
          place: data['place'],
          email: data['email'],
          password: data['password'],
        ),
      );
    } else {
      nextPage = const UserHome();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 300),
              const SizedBox(height: 20),
              const Text(
                "RELIFE",
                style: TextStyle(
                  fontFamily: 'Impact', // Impact font
                  fontSize: 36,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
