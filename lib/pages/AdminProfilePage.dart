import 'package:flutter/material.dart';
import 'package:techxcel11/pages/reuse.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  State<AdminProfile> createState() => _AdminProfile();
}
 
class _AdminProfile extends State<AdminProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBarAdmin(),
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Image.network(
                'https://img.freepik.com/free-icon/user_318-563642.jpg',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
              // Username
              const SizedBox(height: 16),
              // Add your username widget here
            ],
          ),
        ),
      ),
    );
  }
}

//TECHXCEL-LINA
