import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:user_profile_auth/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all user
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  //local profile image file
  File? _profileImage;

  void initState() {
    super.initState();
    _loadProfileImage();
  }

  //load the saved profile image from local storage
  Future<void> _loadProfileImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/profile_picture.jpg';
    final file = File(filePath);

    if (await file.exists()) {
      setState(() {
        _profileImage = file;
      });
    }
  }

  //pick and save a profile picture locally
  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();

    try {
      //step 1: pick an image
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        //step 2: save the image locally
        final appDir = await getApplicationDocumentsDirectory();
        final filePath = '${appDir.path}/profile_picture.jpg';
        final localFile = await File(pickedImage.path).copy(filePath);

        //step 3: update the state with the new image
        setState(() {
          _profileImage = localFile;
        });

        print("Profile image saved at: $filePath");
      }
    } catch (e) {
      print("Error picking or saving image: $e");
    }
  }

  // validation for Name
  bool validateName(String value) {
    final regex = RegExp(r'^[A-Za-zА-Яа-яЁё\s-]{2,50}$');
    return regex.hasMatch(value);
  }

// validation for Surname
  bool validateSurname(String value) {
    final regex = RegExp(r'^[A-Za-zА-Яа-яЁё\s-]{2,50}$');
    return regex.hasMatch(value);
  }

// validation for Job Title
  bool validateJobTitle(String value) {
    final regex = RegExp(r'^[A-Za-zА-Яа-яЁё0-9\s]{1,100}$');
    return regex.hasMatch(value);
  }

// validation for Phone Number
  bool validatePhone(String value) {
    final regex = RegExp(r'^\+[0-9]{10,15}$');
    return regex.hasMatch(value);
  }

// validation for Address
  bool validateAddress(String value) {
    final regex = RegExp(r'^[A-Za-zА-Яа-яЁё0-9\s,.-]{1,200}$');
    return regex.hasMatch(value);
  }

// validation for Pitch (with tag constraints)
  bool validatePitch(String value) {
    final tags = value.split(',').map((e) => e.trim()).toList();
    if (tags.length > 10) return false; // Maximum 10 tags
    for (var tag in tags) {
      if (tag.length > 30 ||
          !RegExp(r'^[A-Za-zА-Яа-яЁё0-9\s,.-]{1,30}$').hasMatch(tag)) {
        return false;
      }
    }
    return true;
  }

  //edit field
  Future<void> editField(String field, String currentValue) async {
    String newValue = currentValue;

    // showin a dialog to allow user to edit the field
    newValue = await showDialog<String>(
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
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                newValue = value;
              },
              controller: TextEditingController(text: currentValue),
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Save button
              TextButton(
                onPressed: () => Navigator.of(context).pop(newValue),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        currentValue;

    // if the new value is not empty and is different from the current value, validate and update
    if (newValue.trim().isNotEmpty && newValue != currentValue) {
      bool isValid = true;

      // validate based on the field
      if (field == 'name') {
        isValid = validateName(newValue);
      } else if (field == 'surname') {
        isValid = validateSurname(newValue);
      } else if (field == 'phone') {
        isValid = validatePhone(newValue);
      } else if (field == 'address') {
        isValid = validateAddress(newValue);
      } else if (field == 'pitch') {
        isValid = validatePitch(newValue);
      } else if (field == 'jobTitle') {
        isValid = validateJobTitle(newValue);
      }

      if (isValid) {
        // proceed with updating the field
        print('Updating field: $field');
        print('New value: $newValue');
        try {
          if (field == 'pitch') {
            final updatedPitchList =
                newValue.split(',').map((e) => e.trim()).toList();
            await usersCollection
                .doc(currentUser.email)
                .update({field: updatedPitchList});
          } else {
            await usersCollection
                .doc(currentUser.email)
                .update({field: newValue});
          }

          // refresh UI to show updated value.
          setState(() {});
        } catch (e) {
          print("Error updating field: $e");
        }
      } else {
        // show validation error message if not valid
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid value for $field. Please check your input.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TROOD. | Profile ",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF90CAF9), Color(0xFFE3F2FD)],
              begin: Alignment.bottomCenter,
              end: Alignment.topLeft),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: usersCollection.doc(currentUser.email).snapshots(),
          builder: (context, snapshot) {
            //get user data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  const SizedBox(height: 20),

                  //profile picture
                  Center(
                    child: GestureDetector(
                      onTap: _pickAndSaveImage,
                      child: _profileImage != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: FileImage(_profileImage!),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.person,
                                size: 40,
                              ),
                            ),
                    ),
                  ),

                  // const SizedBox(
                  //   height: 20,
                  // ),
                  //
                  // //user email
                  // Text(
                  //   currentUser.email!,
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(color: Colors.black87, fontSize: 14),
                  // ),

                  const SizedBox(
                    height: 20,
                  ),

                  //user details
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'My Details',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  // Fields

                  //name
                  MyTextBox(
                    text: userData['name'] ?? 'N/A',
                    sectionName: 'Name',
                    onPressed: () => editField('name', userData['name'] ?? ''),
                  ),

                  //surname
                  MyTextBox(
                    text: userData['surname'] ?? 'N/A',
                    sectionName: 'Surname',
                    onPressed: () =>
                        editField('surname', userData['surname'] ?? ''),
                  ),

                  //phone
                  MyTextBox(
                    text: userData['phone'] ?? 'N/A',
                    sectionName: 'Phone',
                    onPressed: () =>
                        editField('phone', userData['phone'] ?? ''),
                  ),

                  //address
                  MyTextBox(
                    text: userData['address'] ?? 'N/A',
                    sectionName: 'Address',
                    onPressed: () =>
                        editField('address', userData['address'] ?? ''),
                  ),

                  //pitch
                  MyTextBox(
                    text: (userData['pitch'] as List<dynamic>?)?.join(', ') ??
                        'N/A',
                    sectionName: 'Pitch',
                    onPressed: () => editField(
                      'pitch',
                      (userData['pitch'] as List<dynamic>?)?.join(', ') ?? '',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // toggle public/private profile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show your profile in Launchpad?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                usersCollection
                                    .doc(currentUser.email)
                                    .update({'isPublic': true});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: userData['isPublic'] == true
                                      ? Colors.black38
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Public',
                                  style: TextStyle(
                                    color: userData['isPublic'] == true
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                usersCollection
                                    .doc(currentUser.email)
                                    .update({'isPublic': false});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: userData['isPublic'] == false
                                      ? Colors.black38
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Private',
                                  style: TextStyle(
                                    color: userData['isPublic'] == false
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //user posts
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'The scopes of your interests:          Potential interests: ',
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
      ),
    );
  }
}
