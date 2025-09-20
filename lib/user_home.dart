import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:video_app/user_blood_page.dart';
import 'package:video_app/user_donation_page.dart';

import 'widgets/function_card.dart';
import 'shelter_list_page.dart';
import 'product_list_page.dart';
import 'missing_person_list_page.dart';
import 'data/missing_person_data.dart';
import 'user_donation_page.dart';
import 'data/donation_data.dart';
import 'video_gallery_page.dart';
import 'report_issue_page.dart';
import 'volunteer_registration_page.dart';
import 'evacuation_map_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'admin_home.dart';
import 'volunteer_home.dart';
import 'models/volunteer.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
    with SingleTickerProviderStateMixin {
  bool hasNewIssue = false;
  late AnimationController _controller;
  String? role; // "ADMIN" / "VOLUNTEER" / "USER" / null (guest)

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..forward();
    _loadRole();
  }

  void _loadRole() {
    var box = Hive.box('authBox');
    setState(() {
      role = box.get('role'); // get logged-in role
    });
  }

  void _signOut() {
    var box = Hive.box('authBox');
    box.put('isLoggedIn', false);
    box.put('role', null); // set role to null for guest
    box.delete('email');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserHome()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalDonations = donationsList.fold(0, (sum, d) => sum + d.quantity);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        title: Text(
          "Disaster Relief Hub",
          style: GoogleFonts.bebasNeue(fontSize: 28, letterSpacing: 1.2),
        ),
        actions: [
          if (role == "ADMIN" || role == "VOLUNTEER")
            PopupMenuButton<String>(
              icon: const Icon(Icons.switch_account, color: Colors.white),
              onSelected: (value) {
                if (value == "admin") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminHome()),
                  );
                } else if (value == "user") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHome()),
                  );
                } else if (value == "volunteer") {
                  Volunteer volunteerToOpen;

                  if (role == "VOLUNTEER") {
                    var volunteersBox = Hive.box('volunteersBox');
                    String? email = Hive.box('authBox').get('email');

                    if (email != null && volunteersBox.containsKey(email)) {
                      var data = volunteersBox.get(email);
                      volunteerToOpen = Volunteer(
                        name: data['name'],
                        place: data['place'],
                        email: email,
                        password: data['password'],
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Volunteer data not found!")),
                      );
                      return;
                    }
                  } else {
                    volunteerToOpen = Volunteer(
                      name: "Admin Volunteer",
                      place: "Admin Center",
                      email: "admin@admin.com",
                      password: "admin123",
                    );
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VolunteerHome(volunteer: volunteerToOpen),
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                List<PopupMenuEntry<String>> items = [];
                if (role == "ADMIN") {
                  items.add(const PopupMenuItem(
                      value: "admin", child: Text("Admin Home")));
                }
                items.add(const PopupMenuItem(
                    value: "user", child: Text("User Home")));
                items.add(const PopupMenuItem(
                    value: "volunteer", child: Text("Volunteer Home")));
                return items;
              },
            ),
          if (role != null && role != "USER")
            TextButton(
              onPressed: _signOut,
              child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _showFunctionsDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ).createShader(rect),
              blendMode: BlendMode.darken,
              child: Image.network(
                'https://media.istockphoto.com/id/872576234/photo/rescue.jpg?s=612x612&w=0&k=20&c=53Sskdnw4l3O_Wvx6sIcvveWwSxBxT1X-kkrZg-W9Cw=',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _buildAnimatedCard(
                  0,
                  FunctionCard(
                    title: "Shelters",
                    icon: Icons.home,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShelterListPage()),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  1,
                  FunctionCard(
                    title: "Required Products",
                    icon: Icons.shopping_cart,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductListPage(canAdd: false)),
                    ),
                  ),
                ),
                
                _buildAnimatedCard(
                  2,
                  FunctionCard(
                    title: "Missing Persons",
                    icon: Icons.person_search,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MissingPersonListPage(persons: sampleMissingPersons),
                      ),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  3,
                  FunctionCard(
                    title: "Report an Issue",
                    icon: Icons.report_problem,
                    color: Colors.white.withOpacity(0.35),
                    badge: hasNewIssue
                        ? Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () async {
                      final submitted = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportIssuePage()),
                      );
                      if (submitted == true) {
                        setState(() => hasNewIssue = true);
                      }
                    },
                  ),
                ),
                
                _buildAnimatedCard(
                  4,
                  FunctionCard(
                    title: "Volunteer Registration",
                    icon: Icons.group_add,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const VolunteerRegistrationPage()),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  5,
                  FunctionCard(
                    title: "Videos",
                    icon: Icons.video_library,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VideoGalleryPage()),
                    ),
                  ),
                ),
                _buildAnimatedCard(
                  6,
                  FunctionCard(
                    title: "Blood Donation",
                    icon: Icons.bloodtype,
                    color: Colors.white.withOpacity(0.35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserBloodPage()),
                    ),
                  ),
                ),_buildAnimatedCard(
  7,
  FunctionCard(
    title: "Donations ($totalDonations)",
    icon: Icons.volunteer_activism,
    color: Colors.white.withOpacity(0.35),
    onTap: () async {
  var box = Hive.box('authBox'); // or wherever you store logged-in user info
  String userName = box.get('name') ?? "Guest";
  String userContact = box.get('contact') ?? "N/A";
  String userAddress = box.get('address') ?? "N/A";

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserDonationPage(
        userName: userName,
        userContact: userContact,
        userAddress: userAddress, 
      ),
    ),
  );

  setState(() {}); // Refresh donations badge
},

  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.1, 1, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  void _showFunctionsDialog(BuildContext context) {
    int totalDonations = donationsList.fold(0, (sum, d) => sum + d.quantity);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text("Quick Access"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildFunctionItem(context, "Shelters", Icons.home, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShelterListPage()));
              }),
              _buildFunctionItem(
                  context, "Required Products", Icons.shopping_cart, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductListPage(canAdd: false)));
              }),
             
              _buildFunctionItem(
                  context, "Missing Persons", Icons.person_search, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MissingPersonListPage(
                            persons: sampleMissingPersons)));
              }),
              _buildFunctionItem(
                  context, "Report an Issue", Icons.report_problem, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportIssuePage()));
              }),
             
              _buildFunctionItem(
                  context, "Volunteer Registration", Icons.group_add, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VolunteerRegistrationPage()));
              }),
              _buildFunctionItem(context, "Videos", Icons.video_library, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VideoGalleryPage()));
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
