import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/change_password.dart';
import 'package:sign_buddy/front_page.dart';
import 'package:sign_buddy/modules/home_page.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/sign_up.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({Key? key}) : super(key: key);

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  String userId = "";
  String email = "";
  String firstName = "";
  String lastName = "";
  String userLanguage = "";
  String classification = "";
  bool isLoading = true;
  bool isEnglish = true;
  bool _changesSaved = false; 
    


  final List<String> userImages = [
    'assets/user_img/user_1.png',
    'assets/user_img/user_2.png',
    'assets/user_img/user_3.png',
    'assets/user_img/user_4.png',
    'assets/user_img/user_5.png',
    'assets/user_img/user_6.png',
    'assets/user_img/user_7.png',
    'assets/user_img/user_8.png',
    'assets/user_img/user_9.png',
    'assets/user_img/user_10.png',
    'assets/user_img/user_11.png',
    'assets/user_img/user_12.png',
  ];
  
  

  final TextEditingController editFirstName = TextEditingController();
  final TextEditingController editEmail = TextEditingController();
  final TextEditingController editLastName = TextEditingController();
  TextEditingController editClassification = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  


   @override
  void initState() {
    getLanguage().then((value) => getUserAccountData());
    super.initState();
  }

   Future<void> getLanguage() async {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getBool('isEnglish');

      if (mounted) {
        setState(() {
          isEnglish = locale!;
        });
      }
    }

  List<String> classificationOptions = ['Speech Impaired', 'Non-Disabled'];
  

  Future<void> getUserAccountData() async {
    String? id = Auth().getCurrentUserId();
    if (id != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('userData').doc(id).get();
      final data = snapshot.data();

      if (mounted) {
        setState(() {
          userId = id;
          if (data != null && data.containsKey("email")) {
            email = data["email"];
            firstName = data["firstName"];
            lastName = data["lastName"];
            userLanguage = data["language"];
            classification = data["classification"];
          } else {
            email = "";
            firstName = "";
            lastName = "";
            userLanguage = "";
            classification = "";
          }

          // Set initial values for text editing controllers
          editEmail.text = email;
          editFirstName.text = firstName;
          editLastName.text = lastName;
          editClassification.text = classification;


          isLoading = false;
        });
      }
    } else {
      print("User ID is null or empty.");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
    Widget build(BuildContext context) {

      if (Auth().isUserAnonymous()) {
        // If the user is anonymous, display this ui
        return Scaffold(
        body: isLoading
          ? Center(
            child: CircularProgressIndicator(),
          )
          : Stack(
            children: [
              // Background Image
              Image.asset(
                'assets/bg-signbuddy2.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              // Back Button aligned to top-left
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CustomBackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // Image at the top
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/signup-img.png',
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text(
                      isEnglish ? 'Unlock Your Profile – Sign Up Now!' : "Simulan ang Iyong Profile\nMag-sign up Ngayon!",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the sign-up page
                        Navigator.pushReplacement(context, SlidePageRoute(page: const SignupPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 71, 63, 63),
                        backgroundColor: Color(0xFF5BD8FF),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isEnglish ? "Sign up" : "Mag-sign up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      );
    }
    

    // Get the user ID
    String? userId = Auth().getCurrentUserId();

    // Use the user ID to get a randomly selected profile image
    String? selectedProfileImage = getProfileImageForUser(userId);
    String fullName = '$firstName $lastName';
      
    

      // If the user is not anonymous, display the regular profile view
      return Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  // Background Image
                  Image.asset(
                    'assets/bg-signbuddy2.png',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                  ),
                  // Content
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        // Profile Section
                        Container(
                          height: 360,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5A96E3).withOpacity(0.8),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(60),
                              bottomRight: Radius.circular(60),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Back Button
                                Padding(
                                  padding: EdgeInsets.only(top: 35, left: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.arrowLeft,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      onPressed: () {
                                       Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (BuildContext context) => HomePage()), 
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  // Use the randomly selected profile image
                                  backgroundImage: selectedProfileImage != null
                                      ? AssetImage(selectedProfileImage)
                                      : AssetImage('assets/user_man.png'), // Provide a default image if needed
                                  ),
                                ),
                                SizedBox(height: 8),
                                Center(
                                    child: Text(
                                      (firstName.length > 9 || lastName.length > 9)
                                          ? '$firstName\n$lastName'
                                          : fullName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center, // To align the text in the center horizontally
                                    ),
                                  ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _editProfileForm,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.deepPurpleAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                  ),
                                  child: Text(
                                    isEnglish ? 'Edit profile' : 'I-Edit ang Profile',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // User Info Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                            padding: EdgeInsets.only(bottom: 16, left: 16), 
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'FiraSans',
                                  color: Color.fromARGB(255, 71, 63, 63)
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildUserInfoItem(firstName, isEnglish ? 'First name' : 'Pangalan', FontAwesomeIcons.solidUser),
                                    _buildDivider(),
                                    _buildUserInfoItem(lastName,  isEnglish ? 'Last name' : 'Apelyido', FontAwesomeIcons.solidUser),
                                    _buildDivider(),
                                    _buildUserInfoItem(email, 'Email', FontAwesomeIcons.solidEnvelope),
                                    _buildDivider(),
                                    _buildUserInfoItem(classification,  isEnglish ? 'Classification' : 'Klasipikasyon', FontAwesomeIcons.solidAddressBook),
                                    _buildDivider(),
                                    _buildLanguageItem(
                                      userLanguage,  isEnglish ? 'Language' : 'Wikang Pangsenyas' , isEnglish ? 'assets/america.png' : 'assets/ph.png',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        _showSignOutConfirmationDialog();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: Colors.grey),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                      ),
                                      child: Text(
                                         isEnglish ? 'Sign Out' : 'Mag-sign out',
                                        style: TextStyle(fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Progress Sectiion
                        SizedBox(height: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 16, left: 16),
                              child: Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'FiraSans',
                                  color: Color.fromARGB(255, 71, 63, 63),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProgressListTile(
                                      label: isEnglish ? 'Alphabet' : 'Alpabeto',
                                      iconPath: 'assets/lesson-icon/img1.png',
                                      lessonType: 'letters',
                                    ),
                                    _buildDividerForProgress(),
                                     _buildProgressListTile(
                                      label: isEnglish ? 'Numbers' : 'Mga Numero',
                                      iconPath: 'assets/lesson-icon/img2.png',
                                      lessonType: 'numbers',
                                    ),
                                    _buildDividerForProgress(),
                                    _buildProgressListTile(
                                        label: isEnglish ? 'Animals' : 'Mga Hayop',
                                        iconPath: 'assets/lesson-icon/img6.png',
                                        lessonType: 'animals',
                                      ),
                                    _buildDividerForProgress(),
                                    _buildProgressListTile(
                                        label: isEnglish ? 'Colors' : 'Mga Kulay',
                                        iconPath: 'assets/lesson-icon/img4.png',
                                        lessonType: 'color',
                                      ),
                                    _buildDividerForProgress(),
                                    _buildProgressListTile(
                                      label: isEnglish ? 'Family' : 'Pamilya',
                                      iconPath: 'assets/lesson-icon/img3.png',
                                      lessonType: 'family',
                                    ),
                                    _buildDividerForProgress(),
                                   _buildProgressListTile(
                                      label: isEnglish ? 'Greetings' : 'Pagbati',
                                      iconPath: 'assets/lesson-icon/img10.png',
                                      lessonType: 'greetings',
                                    ),        
                                   
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Privacy
                        SizedBox(height: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 16, left: 16),
                              child: Text(
                                'Privacy',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'FiraSans',
                                  color: Color.fromARGB(255, 71, 63, 63),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildListTile(
                                      icon: FontAwesomeIcons.key,
                                      text:  isEnglish ? 'Change password' : 'Magpalit ng password',
                                      onPressed: () {
                                        Navigator.push(context, SlidePageRoute(page: const ChangePassword()));
                                      },
                                       iconTextSpacing: 18.0 // Customize the spacing for this ListTile
                                    ),
                                    _buildDivider(),
                                    _buildListTile(
                                      icon: FontAwesomeIcons.userXmark,
                                      text:  isEnglish ? 'Delete account' : 'Mag-delete ng account',
                                      onPressed: () async {
                                        _showDeleteConfirmationDialog();
                                      },
                                      iconTextSpacing: 12.0 // Customize the spacing for this ListTile
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
  

  Future<void> _editProfileForm() async {
    // Create copies of original values
    String originalFirstName = editFirstName.text;
    String originalLastName = editLastName.text;
    String originalEmail = editEmail.text;
    String originalClassification = classification;
    String originalClassificationInput = editClassification.text;


    // Get the user ID
      String? userId = Auth().getCurrentUserId();

      // Use the user ID to get a randomly selected profile image
      String? selectedProfileImage = getProfileImageForUser(userId);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg-signbuddy2.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                AppBar(
                                  title: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF5A96E3).withOpacity(0.8),
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(50),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.grey,
                                      // Use the randomly selected profile image
                                      backgroundImage: selectedProfileImage != null
                                          ? AssetImage(selectedProfileImage)
                                          : AssetImage('assets/user_man.png'), // Provide a default image if needed
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                _buildCard(
                                  children: [
                                    TextFormField(
                                      key: Key('firstNameField'),
                                      controller: editFirstName,
                                      decoration: InputDecoration(
                                        hintText:  isEnglish ? 'Enter your first name' : 'Ilagay ng pangalan',
                                        suffixIcon: Icon(FontAwesomeIcons.solidUser, color: Colors.deepPurpleAccent),
                                        border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        CustomInputFormatter(maxLength: 15),
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return isEnglish ? "Please enter your first name" : "Pakilagay ang iyong pangalan";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      key: Key('lastNameField'),
                                      controller: editLastName,
                                      decoration: InputDecoration(
                                        hintText:  isEnglish ? 'Enter your last name' : 'Ilagay ang apelyido',
                                        suffixIcon: Icon(FontAwesomeIcons.solidUser, color: Colors.deepPurpleAccent),
                                        border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        CustomInputFormatter(maxLength: 15),
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return isEnglish ? "Please enter your last name" : "Pakilagay ang iyong apelyido";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: editEmail,
                                      key: Key('emailField'),
                                      decoration: InputDecoration(
                                        hintText:  isEnglish ? 'Enter your email' : 'Ilagay ang iyong email',
                                        suffixIcon: Icon(FontAwesomeIcons.solidEnvelope, color: Colors.deepPurpleAccent),
                                        border: OutlineInputBorder(),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.deepPurpleAccent,
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        EmailInputFormatter(maxLength: 30),
                                      ],
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return isEnglish ? "Please enter your email" : "Pakilagay ang iyong email";
                                        } else if (!RegExp(
                                            r'^[a-zA-Z]+[\w-]*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                                            .hasMatch(value)) {
                                          return isEnglish ? "Please enter a valid email" : "Pakilagay ng wastong email";
                                        } else if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
                                          return isEnglish
                                              ? "Email cannot consist of numbers only"
                                              : "Ang email ay hindi maaaring binubuo ng mga numero lamang";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () {
                                          _showClassificationDialog();
                                        },
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            key: Key('classificationField'),
                                            controller: editClassification,
                                            decoration: InputDecoration(
                                              hintText: isEnglish ? 'Select classification' : 'Pumili ng klasipikasyon',
                                              suffixIcon: Icon(Icons.radio_button_checked, color: Colors.deepPurpleAccent),
                                              border: OutlineInputBorder(),
                                              focusedBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.deepPurpleAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: double.infinity,

                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                _showConfirmationDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5BD8FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(16.0),
                              ),
                              child: Text(isEnglish ? 'Save Changes' : 'I-save ang mga pagbabago', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    // If the user did not save changes, restore the original values
    if (!_changesSaved) {
      if (mounted) {
        setState(() {
          editFirstName.text = originalFirstName;
          editLastName.text = originalLastName;
          editEmail.text = originalEmail;
          classification = originalClassification;
          editClassification.text = originalClassificationInput;

        });
      }
    }
  }


Future<int> getProgressValue(bool isEnglish, String lessonType) async {
    String userId = Auth().getCurrentUserId()!;
    String languageCode = isEnglish ? 'en' : 'ph';

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(userId)
              .collection(lessonType)
              .doc(languageCode)
              .collection('lessons')
              .get();

      int totalProgress = 0;

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        int progressValue = doc['progress'] ?? 0;
        totalProgress += progressValue;
      }

      return totalProgress;
    } catch (e) {
      print('Error getting progress value: $e');
      return 0; // Default value in case of an error
    }
  }

   Future<int> getTotalProgressValue(bool isEnglish, String lessonType) async {
    String userId = Auth().getCurrentUserId()!;
    String languageCode = isEnglish ? 'en' : 'ph';

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(userId)
              .collection(lessonType)
              .doc(languageCode)
              .collection('lessons')
              .get();

      int numberOfDocuments = querySnapshot.size;
      int totalProgressValue = numberOfDocuments * 100;

      return totalProgressValue;
    } catch (e) {
      print('Error getting total progress value: $e');
      return 0; // Default value in case of an error
    }
  }

Widget _buildProgressListTile({
  required String label,
  required String iconPath,
  required String lessonType,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Padding(
      padding: EdgeInsets.only(right: 8.0), 
      child: Image.asset(
        iconPath,
        width: 40, 
        height: 40, 
      ),
    ),
    title: buildProgressIndicator(lessonType, label),
  );
}

Widget buildProgressIndicator(String lessonType, String label) {
  return FutureBuilder<int>(
    future: getProgressValue(isEnglish, lessonType),
    builder: (context, progressSnapshot) {
      return FutureBuilder<int>(
        future: getTotalProgressValue(isEnglish, lessonType),
        builder: (context, totalProgressSnapshot) {
          if (progressSnapshot.connectionState == ConnectionState.waiting ||
              totalProgressSnapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator(); // Show a loading indicator while fetching data
          } else if (progressSnapshot.hasError || totalProgressSnapshot.hasError) {
            return Text('Error fetching progress data');
          } else {
            int progress = progressSnapshot.data ?? 0;
            int totalProgress = totalProgressSnapshot.data ?? 0;
            int percentage = totalProgress > 0 ? (progress / totalProgress * 100).toInt() : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'FiraSans'),
                      ),
                    ),
                    Text(
                      '$percentage%', // Display formatted percentage as a whole number
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'FiraSans', fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0), // Set border radius here
                    color: Colors.grey[300], // Change the background color
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // ClipRRect with same border radius
                    child: LinearProgressIndicator(
                      value: totalProgress > 0 ? progress / totalProgress : 0.0,
                      minHeight: 15,
                      backgroundColor: Colors.transparent, // Make the background color transparent
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Change the color of the completed part
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    },
  );
}

void _showClassificationDialog() {
  String? originalClassification = classification;
  String? selectedValue = classification;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SimpleDialog(
            title: Text(isEnglish ? 'Select classification' : 'Pumili ng klasipikasyon',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'FiraSans'
            )),
            children: [
              ...classificationOptions.map((String value) {
                return RadioListTile<String>(
                  title: Text(value),
                  value: value,
                  groupValue: selectedValue,
                  onChanged: (String? newValue) {
                    if (mounted) {
                      setState(() {
                        selectedValue = newValue;
                        classification = newValue ?? "";
                      });
                    }
                  },
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.only(right: 15, top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Reset the classification to the original value
                        if (mounted) {
                          setState(() {
                            classification = originalClassification;
                          });
                        }
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black45,
                          fontFamily: 'FiraSans'
                        ),
                      ),
                    ),
                    SizedBox(width: 10),    
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        editClassification.text = classification;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      ),
                      child: Text(
                        'Okay',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// Modify _saveChanges method to handle classification restoration
Future<void> _saveChanges() async {
  // Perform necessary logic to save changes to the Firestore database
  String id = Auth().getCurrentUserId()!;
  await FirebaseFirestore.instance.collection('userData').doc(id).update({
    'email': editEmail.text,
    'firstName': editFirstName.text,
    'lastName': editLastName.text,
    'classification': classification,
  });

  // Update local state immediately
  if (mounted) {
    setState(() {
      email = editEmail.text;
      firstName = editFirstName.text;
      lastName = editLastName.text;
      _changesSaved = true;
    });
  }


  Navigator.of(context).pop(); // Close the edit profile page
  showCustomSnackBar(
        context,
    isEnglish? "Profile changed successfully" : "Matagumpay na nabago ang profile",
  );
}




  @override
  void dispose() {
    // Dispose the text editing controllers when the State is disposed
    editFirstName.dispose();
    editEmail.dispose();
    editLastName.dispose();
    

    super.dispose();
  }

  

 Widget _buildListTile({required IconData icon, required String text, required VoidCallback onPressed, double iconTextSpacing = 0}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Row(
      children: [
        FaIcon(
          icon,
          color: Colors.deepPurpleAccent,
        ),
        SizedBox(width: iconTextSpacing), // Adjust the spacing between icon and text
        Text(
          text,
          style: TextStyle(
            color: Color.fromARGB(255, 71, 63, 63),
            fontSize: 16,
            fontFamily: 'FiraSans',
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    ),
    onTap: onPressed,
  );
}
  // for privacy and user data card
  Widget _buildDivider() {
    return Divider(
      color: Colors.deepPurpleAccent,
      height: 5,
      thickness: 1,
    );
  }
  // for Progress
  Widget _buildDividerForProgress() {
    return Divider(
      color: Colors.deepPurpleAccent,
      height: 20,
      thickness: 1,
    );
  }


  //randomly gives the user an profile image
  String? getProfileImageForUser(String? userId) {
      if (userId == null) {
        // Handle the case where userId is null (if needed)
        return null;
      }

  
      // Use the user ID to generate a random index for selecting a profile image
      int randomIndex = userId.hashCode % userImages.length;

      // Ensure the index is non-negative
      randomIndex = randomIndex < 0 ? -randomIndex : randomIndex;

      // Return the selected profile image
      return userImages[randomIndex];
    }




  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  

  Future<void> _showConfirmationDialog() async {
    if (_formKey.currentState!.validate()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange, 
                ),
                SizedBox(width: 8), // Add some space between the icon and text
                Text(isEnglish ? 'Confirm Changes' : 'Kumpirmahin', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(isEnglish ? 'Are you sure you want to save the changes?' : 'Sigurado ka bang nais mong i-save ang mga pagbabago', style: TextStyle(fontFamily: 'FiraSans')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black45, 
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveChanges();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                ),
                child: Text(
                  isEnglish ? 'Confirm' : 'Kumpirmahin',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      );
    }
}



  

  Future<void> _showSignOutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
              ),
              SizedBox(width: 8), // Add space between the icon and text
              Text(
                isEnglish ? 'Confirm Sign Out' : 'Kumpirmahin',
                style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(isEnglish ?  'Are you sure you want to sign out?' : "Sigurado ka bang nais mong mag-sign out?", style: TextStyle(fontFamily: 'FiraSans')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                
                await Auth().signOut();

                await getLanguage();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => const FrontPage()),
                    (route) => false);
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16 )
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.redAccent,
              ),
              SizedBox(width: 8),
              Text(isEnglish ? 'Confirm Deletion' : 'Kumpirmahin', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'FiraSans', color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: isEnglish ? 'Are you sure you want to delete your account?\n\n' : 'Sigurado ka bang nais mong burahin ang iyong account?\n\n',
                ),
                TextSpan(
                  text: isEnglish ? 'This action cannot be undone': 'Hindi maaaring bawiin ang hakbang na ito',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black45,
                  fontFamily: 'Fira Sans'
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAccount();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  
  //function that deletes account of registered user..
  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(isEnglish ? 'Deleting account...' : 'Pagbubura ng account'),
            ],
          ),
        );
      },
    );
    // Perform necessary logic to delete the account from the Firestore database
    String? userId = Auth().getCurrentUserId();

    try {
      // Show a loading dialog
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false, // Make the loading page non-opaque
            pageBuilder: (context, _, __) {
              return const Loading(text: 'Loading . . . '); 
            },
          ),
        );

      if(userId != null) {
        await FirebaseFirestore.instance
        .collection('userData')
        .doc(userId)
        .delete();

        // Delete the user from Firebase Authentication
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
        }

        await Auth().signOut();
        // Close the loading dialog
        if (!context.mounted) return;
        Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const FrontPage()),
        (route) => false);

        showCustomSnackBar(
          context,
          "Account deleted successfully",
      );

      } else {
          // Handle the case where user ID is null
          print("User ID is null or empty.");
          Navigator.pop(context);
        }
      } catch (e) {
          // Handle errors, e.g., show an error dialog
          print("Error deleting progress: $e");
          Navigator.pop(context); // Close the loading dialog
        }

  }

    //snackbar function that display the erros and succession state
    void showCustomSnackBar(BuildContext context, String message) {
      final snackBar = SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'FiraSans',
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF36454F), 
        duration: Duration(seconds: 3), 
        behavior: SnackBarBehavior.floating,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }



  // widget for language display
  Widget _buildLanguageItem(String label, String value, String imagePath) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        height: 24, 
        width: 24, 
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
      ),
    );
  }

  
  //widget for User Info
  Widget _buildUserInfoItem(String label, String value, IconData iconData) {
    return ListTile(
      leading: Icon(iconData, color: Colors.deepPurpleAccent),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
      ),
    );
  }

  
}


class CustomInputFormatter extends TextInputFormatter {
  final int maxLength;

  CustomInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only alphabetic characters with zero or one space
    final RegExp regExp = RegExp(r'^[a-zA-Z]*( [a-zA-Z]*)?$');

    // Remove spaces from the character count
    final int actualLength = newValue.text.replaceAll(' ', '').length;

    // Check if the new value exceeds the maximum length
    if (actualLength > maxLength) {
      // Truncate the text to the maximum length
      final truncatedText = _truncateText(newValue.text, maxLength);
      
      // Return the truncated text with the updated selection
      return TextEditingValue(
        text: truncatedText,
        selection: TextSelection.collapsed(offset: truncatedText.length),
      );
    }

    // If the input matches the allowed pattern, capitalize the first letter
    if (regExp.hasMatch(newValue.text)) {
      return capitalizeFirstLetter(newValue);
    }

    // If the input doesn't match the pattern, revert to the old value
    return oldValue;
  }

  TextEditingValue capitalizeFirstLetter(TextEditingValue value) {
    // Capitalize the first letter
    String newText = value.text;
    if (newText.isNotEmpty) {
      newText = newText[0].toUpperCase() + newText.substring(1);
    }
    return TextEditingValue(
      text: newText,
      selection: value.selection,
    );
  }

  String _truncateText(String text, int maxLength) {
    // Truncate the text to the maximum length
    if (text.length > maxLength) {
      final truncatedText = text.substring(0, maxLength);
      return truncatedText.replaceAll(' ', ''); // Remove spaces from the truncated text
    }
    return text;
  }
}



class EmailInputFormatter extends TextInputFormatter {
  final int maxLength;

  EmailInputFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow alphabetic characters, numbers, "@" and ".", and disallow spaces
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9@.]*$');

    // Check if the new value exceeds the maximum length
    if (newValue.text.length > maxLength) {
      // Truncate the text to the maximum length
      final truncatedText = newValue.text.substring(0, maxLength);

      // Return the truncated text with the updated selection
      return TextEditingValue(
        text: truncatedText,
        selection: TextSelection.collapsed(offset: maxLength),
      );
    }
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    

    return oldValue;
  }
  
}