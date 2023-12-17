import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';
import 'package:sign_buddy/change_password.dart';
import 'package:sign_buddy/front_page.dart';
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
                    image: AssetImage('assets/bg-signbuddy.png'),
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
                                      hintText: 'Enter your first name',
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
                                      hintText: 'Enter your last name',
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
                                      hintText: 'Enter your email',
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
                                            hintText: 'Select classification',
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
                            child: Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
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
            title: Text('Select Classification', 
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
}




  @override
  void dispose() {
    // Dispose the text editing controllers when the State is disposed
    editFirstName.dispose();
    editEmail.dispose();
    editLastName.dispose();
    

    super.dispose();
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
                'assets/bg-signbuddy.png',
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
                      "Unlock Your Profile – Sign Up Now!",
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
                        'Sign Up',
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
                    'assets/bg-signbuddy.png',
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
                          height: 330,
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
                                       Navigator.pop(context);
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
                                Text(
                                  '$firstName $lastName',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                                    'Edit profile',
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
                                    _buildUserInfoItem(firstName, 'First name', FontAwesomeIcons.solidUser),
                                    _buildDivider(),
                                    _buildUserInfoItem(lastName, 'Last name', FontAwesomeIcons.solidUser),
                                    _buildDivider(),
                                    _buildUserInfoItem(email, 'Email', FontAwesomeIcons.solidEnvelope),
                                    _buildDivider(),
                                    _buildUserInfoItem(classification, 'Classification', FontAwesomeIcons.solidAddressBook),
                                    _buildDivider(),
                                    _buildLanguageItem(
                                      userLanguage,
                                      'Language',
                                      isEnglish ? 'assets/america.png' : 'assets/ph.png',
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
                                        'Sign out',
                                        style: TextStyle(fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
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
                                      text: 'Change password',
                                      onPressed: () {
                                        Navigator.push(context, SlidePageRoute(page: const ChangePassword()));
                                      },
                                       iconTextSpacing: 18.0 // Customize the spacing for this ListTile
                                    ),
                                    _buildDivider(),
                                    _buildListTile(
                                      icon: FontAwesomeIcons.userXmark,
                                      text: 'Delete account',
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

  Widget _buildDivider() {
    return Divider(
      color: Colors.deepPurpleAccent,
      height: 5,
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
                Text('Confirm Changes', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('Are you sure you want to save the changes?', style: TextStyle(fontFamily: 'FiraSans')),
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
                  'Confirm',
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
                'Confirm Sign Out',
                style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'FiraSans')),
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
                 // Update language preference after signing out
                await getLanguage();
                // Navigate back to the home screen or any other screen
                 // Navigate back to the home screen or any other screen
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
              Text('Confirm Deletion', style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.bold)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'FiraSans', color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: 'Are you sure you want to delete your account?\n\n',
                ),
                TextSpan(
                  text: 'This action cannot be undone.',
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
              Text('Deleting account...'),
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

    // If the input matches the allowed pattern, allow the new value
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }

    // If the input doesn't match the pattern, revert to the old value
    return oldValue;
  }
  
}