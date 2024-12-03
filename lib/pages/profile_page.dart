import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_profile_auth/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //edit field
  Future<void> editField(String field) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          //profile picture
          const Icon(
            Icons.person,
            size: 72,
          ),

          const SizedBox(
            height: 10,
          ),

          //user email
          Text(
            currentUser.email!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),

          const SizedBox(
            height: 50,
          ),

          //user details
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'My Details',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          //username
          MyTextBox(
            text: 'Anwar',
            sectionName: 'username',
            onPressed: () => editField('username'),
          ),
          //bio
          MyTextBox(
            text: 'Anwar',
            sectionName: 'username',
            onPressed: () => editField(
              'bio',
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          //user posts
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              'My Posts',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
