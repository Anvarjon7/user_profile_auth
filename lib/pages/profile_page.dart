import 'package:cloud_firestore/cloud_firestore.dart';
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

  //all user
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: Colors.grey)),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              )),

          //save button
          TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    );

//update in firestore
    if (newValue.trim().length > 0) {
      //only update if there is something in the textfield
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          //get user data
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
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
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                //bio
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
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
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
