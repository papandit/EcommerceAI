                                                                                                  
                                   WELCOME TO [E-COMMERCE ADMIN PANEL]                                            
                                                                                                  
    Greetings,                                                                                    
                                                                                                  
    We extend our sincere appreciation for your interest in [T_Admin_Panel]. This repository            
    houses a robust e-commerce solution developed using the Flutter framework. Every line         
    of code here reflects our commitment to quality, efficiency, and scalability.                 
                                                                                                  
    We're dedicated to continuous improvement and we welcome feedback to make this                
    solution even more industry-leading. Dive in, explore, and let's innovate together.           
                                                                                                  
    Regards,                                                                                      
    Coding with T


## Install dependencies:
    flutter pub get


## Setup Firebase Project

YouTube Video
https://youtu.be/91fmyvqBoEo?si=Rnl6xd6te04VOjEt
┌─── SETUP FIREBASE ───────────────────────────────────────────────────────────────────────────────┐
|                                                                                                  |
|    1️⃣ Initialize Packages: Begin by fetching all necessary packages.                             |
|        Execute the following in your terminal: `flutter pub get`.                                |
|                                                                                                  |
|    2️⃣ Firebase Setup: Watch this tutorial to setup Firebase using CLI                            |
|        https://www.youtube.com/watch?v=fxDusoMcWj8                                               |
|                                                                                                  |
|    3️⃣ Connect Firebase Project: In the terminal run `flutterfire configure` command              |
|        [ERROR]: flutter-fire command not found                                                   |
|        [SOLUTION]: Check your Environment variables. The path is not properly added.             |
|        Next: Select your project from the list of projects and you are good to go.               |
|                                                                                                  |
|    4️⃣ Enable Firebase Services:                                                                  |  
|        In the Firebase Console, select your project.                                             |
|        Follow the steps below to enable necessary services:                                      |
|                                                                                                  |
|        Authentication:                                                                           |
|           * Click on "Authentication" in the left sidebar.                                       |
|           * Navigate to the "Sign-in method" tab.                                                |
|           * Enable the authentication methods you want (e.g., Google, Facebook, Email/Password). |
|                                                                                                  |
|        Firestore (Database):                                                                     |
|           * Click on "Firestore" in the left sidebar.                                            |
|           * Click on "Create Database" and choose the location.                                  |
|           * Select "Start in test mode" for development purposes.                                |             
|                                                                                                  |
|        Storage:                                                                                  |
|           * Click on "Storage" in the left sidebar.                                              |
|           * Click on "Get Started."                                                              |             
|           * Follow the setup instructions.                                                       |
|                                                                                                  |
|    5️⃣ Generate SHA1 and SHA256 fingerprints:                                                     |    
|        * Go to the project folder in the terminal.                                               |
|                                                                                                  |
|           **Mac:**                                                                               |     
|           keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
|                                                                                                  |
|           **Windows:**                                                                           |
|           keytool -list -v -keystore "\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
|                                                                                                  |
|           **Linux:**                                                                             |     
|           keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
|                                                                                                  |
|           [WINDOWS Example]:                                                                     |
|           keytool -list -v -keystore "C:\Users\Your PC Name\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
|           `Here You will get SHA1 and SHA256 Keys`
|                                                                                                  |
|    6️⃣ Add SHA1 and SHA256 Fingerprints to Firebase Console:                                     |
|        * Navigate to Project settings(Gear Icon in front of Project Overview)                    |             
|        * Go to General tab > Your apps.                                                          |
|        * Select your app and navigate to the "Add fingerprints" button.                          |             
|        * Add both `SHA-1` and `SHA-256` fingerprints.                                            |
|                                                                                                  |
|                                                                                                  |
└──────────────────────────────────────────────────────────────────────────────────────────────────┘




## Media Unable to load Images [Create Index in Firestore Firebase]
  Add index in the Firestore index by going into Firebase console of your project. 
  Select Firestore database and then select indexes from top menu. 
  Click on Add index button in the composite tab and fill the form as below.

    Collection Id = Images
    Fields to index:  
      mediaCategory = Ascending
      createdAt = Descending
      __name__ = Descending
    Query Scopes = Collection
    
  Note: In the **name** there are two underscores at the start and end.
  Wait for the Index to be Enabled.




## Enable CORS to view Images
  Login to your google cloud console: https://console.cloud.google.com/home. 
  Select the same Firebase Project from the top left menu.
  Click on "Activate Google Cloud Shell" in the upper right corner icon.

  At the bottom of your window, a shell terminal will be shown, where gcloud and gsutil are already
  available. Execute the command shown below. It creates a json-file which is needed to setup the 
  cors-configuration for your bucket. This configuration will allow every domain to access your 
  bucket using XHR-Requests in the browser.

    echo '[{"origin": ["*"],"responseHeader": ["Content-Type"],"method": ["GET", "HEAD"],"maxAgeSeconds": 3600}]' > cors-config.json
  
  Replace ~~YOUR_BUCKET_NAME~~ with your actual bucket which is in the 
  Firebase Console -> Storage -> Copy the gs://,,, bucket name and replace with the below command.
    
    gsutil cors set cors-config.json gs://YOUR_BUCKET_NAME

  Run this command in the Google shell terminal and you are done.

  To check if everything worked as expected, you can get the cors-settings of a bucket with the 
  following command: 
  
    gsutil cors get gs://YOUR_BUCKET_NAME





# **Register Admin**

- Go to lib => features => authentication => screens => login => widgets => login_form.dart
- Find ElevatedButton() in the end
- Replace controller.emailAndPasswordSignIn() with controller.registerAdmin()
- `Modify Admin Credentials`
- Go to lib => utils => constants => text_strings.dart
- Change adminEmail and adminPassword
- `Sign In`
- Run the code and press `Register Admin` button
- `Modify SignIn buttton function`
- After Logged in
- Go to lib => features => authentication => screens => login => widgets => login_form.dart
- Find ElevatedButton() in the end
- Replace controller.registerAdmin() with controller.emailAndPasswordSignIn()





## Firebase Hosting

### Prerequisites
Before deploying to Firebase Hosting, ensure you have the following:

- Firebase account
- Firebase CLI installed (if not, install it using `npm install -g firebase-tools`)
- Initialize Firebase in your project directory:
- 
- Navigate to your project directory and run: 
- # Step 1
- Select Firebase services:
- During initialization, choose Firebase Hosting as the service you want to use. 
- 
- Build your project for production:
- Before deploying, build your Flutter project for production:
- 
- Deploy to Firebase Hosting:
- Once your project is built, deploy it to Firebase Hosting using the Firebase CLI:
- 
- Access your deployed website:
- Firebase will provide you with a hosting URL where your website is deployed. You can access it via the provided URL.



######  Steps
1. **Configure Firebase Project**:
   ```bash
   flutterfire configure
      
2. **Install the Firebase CLI**:
   ```bash
   npm install -g firebase-tools   
   
3. **Create Flutter Web Build**:
   ```bash
   firebase init
   
- Are you ready to proceed? Yes
- Which Firebase features do you want to set up for this directory? Press Space to select features, then Enter to confirm your choices. (firestore, hosting(configure file), Storage)

- === Project Setup
- Please select an option: Use an existing project
- Select a default Firebase project for this directory: Enter

- === Firestore Setup
- What file should be used for Firestore Rules? firestore.rules (Enter)
- File firestore.rules already exists. Do you want to overwrite it with the Firestore Rules from the Firebase Console? Yes
- What file should be used for Firestore indexes? firestore.indexes.json (Enter)
- File firestore.indexes.json already exists. Do you want to overwrite it with the Firestore Indexes from the Firebase Console? Yes

- === Hosting Setup
- What do you want to use as your public directory? build/web
- Configure as a single-page app (rewrite all urls to /index.html)? Yes
- Set up automatic builds and deploys with GitHub? No

- === Storage Setup
- What file should be used for Storage Rules? storage.rules
- File storage.rules already exists. Overwrite? Yes

4. **Deploy on Firebase**:
   ```bash
   flutter build web --release --no-tree-shake-icons
   
5. **Init the Firebase**:
   ```bash
    firebase deploy --only hosting





# Error Handling
While using the project, you may encounter the following errors:

    404 Not Found: This error occurs when the requested resource is not found. Ensure that the URL is correct and the resource exists.
    500 Internal Server Error: This error indicates a problem with the server. Check server logs for more information and try again later.
    Network Errors: Errors related to network connectivity issues. Verify internet connection and try again.
    Cross-Origin Resource Sharing (CORS) Errors: Occurs when making requests to a different domain. Configure CORS settings on the server or use a proxy.


    1. Target of URI doesn't exist: 'dart:html'

    This error occurs when you try to use dart:html library in a Flutter web project. However, dart:html is not supported in Flutter web. Instead, you should use the dart:html equivalent libraries provided by Flutter web.
    Solution: Use the dart:html equivalent libraries provided by Flutter web, such as dart:ui, html, and package:flutter/material.dart.

    2. Unsupported operation: Platform views are not supported.

    This error occurs when you try to use platform views, such as WebView, in a Flutter web project. However, platform views are not supported in Flutter web.
    Solution: Use Flutter web-specific packages for web views, such as flutter_inappwebview or webview_flutter.

    3. Failed assertion: line 1785 pos 12: 'owner._debugCurrentBuildTarget == this': is not true.

    This error occurs when you try to use a widget that is not designed to be used in a web project.
    Solution: Use widgets that are designed to be used in a web project, such as HtmlElementView, InteractiveViewer, and MouseRegion.

    4. Unhandled Exception: Null check operator used on a null value

    This error occurs when you try to access a null value using the ! operator.
    Solution: Always check if a value is null before using the ! operator. You can use the?. operator to safely access nullable values.

    5. Unhandled Exception: Concurrent modification during iteration: Instance of 'List<dynamic>'

    This error occurs when you try to modify a list while iterating over it.
    Solution: Use the List.asMap() method to iterate over a list and modify it at the same time.

    6. Unhandled Exception: NoSuchMethodError: The method '[]' was called on null.

    This error occurs when you try to access an index of a null list.
    Solution: Always check if a list is null before accessing its index. You can use the ?. operator to safely access nullable lists.

    7. Unhandled Exception: Failed assertion: line 1485 pos 12: 'data != null': is not true.

    This error occurs when you try to use a null ImageProvider with the Image widget.
    Solution: Always check if an ImageProvider is null before using it with the Image widget. You can use the ?. operator to safely access nullable ImageProviders.

    8. Unhandled Exception: type 'String' is not a subtype of type 'int' of 'index'

    This error occurs when you try to access an index of a string using an integer.
    Solution: Always convert an integer to a string before using it as an index of a string. You can use the .toString() method to convert an integer to a string.

    9. Unhandled Exception: type 'double' is not a subtype of type 'int' of 'index'

    This error occurs when you try to access an index of a list using a double.
    Solution: Always convert a double to an integer before using it as an index of a list. You can use the .toInt() method to convert a double to an integer.










# Support
   For support, please contact [support@codingwitht.com] or visit [https://codingwitht.com/].
   
# Contributing
   Contributions to this project are welcome! To contribute, please follow our contributing guidelines.

# License
   This project is licensed under the MIT License.
