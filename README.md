# User Profile App

### Overview
The User Profile App is a Flutter-based mobile application that enables users to authenticate, manage their profiles, and share messages in a social "wall" environment. 
It is integrated with Firebase for real-time data handling and secure authentication. 
The app offers a seamless and user-friendly interface for a better user experience.


### Technologies and Libraries
- **Framework**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
# Plugins and Dependencies:
- *firebase_auth*: User authentication
- *cloud_firestore*: Real-time database
- *image_picker*: Select and upload profile pictures
- *path_provider*: File system paths for profile management


### How to Run the App
1. Prerequisites:
Install Flutter.
Set up Firebase for your project (add Firebase configuration files to your app).
2. Clone the Repository:
-- git clone https://github.com/Anvarjon7/user_profile_auth
-- cd user_profile_auth
3. Install Dependencies: Run the following command to install all required packages:
-- run this command -> flutter pub get
4. Set Up Firebase:
-- Add google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the respective directories as per Firebase setup instructions.
5. Run the App: Start the app on an emulator or physical device:
-- run -> flutter run


### App Screens
* *Login Page* : Users can sign in with their credentials.
* *Register Page* : New users can create an account.
* *Home Page*: A public "wall" where users can post and read messages.
* *Profile Page*: Displays and allows editing of user information, including profile pictures.
