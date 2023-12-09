import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/auth.dart';

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
  bool isLoading = true;
  bool isEnglish = true;
  bool _changesSaved = false; // Add this line

  final TextEditingController editFirstName = TextEditingController();
  final TextEditingController editEmail = TextEditingController();
  final TextEditingController editLastName = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   @override
  void initState() {
    getLanguage().then((value) => getUserAccountData());
    super.initState();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  Future<void> getUserAccountData() async {
    String? id = Auth().getCurrentUserId();
    if (id != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('userData').doc(id).get();
      final data = snapshot.data();

      setState(() {
        userId = id;
        if (data != null && data.containsKey("email")) {
          email = data["email"];
          firstName = data["firstName"];
          lastName = data["lastName"];
          userLanguage = data["language"];
        } else {
          email = "";
          firstName = "";
          lastName = "";
          userLanguage = "";
        }

        // Set initial values for text editing controllers
        editEmail.text = email;
        editFirstName.text = firstName;
        editLastName.text = lastName;

        isLoading = false;
      });
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
                  child: Form(
                    key: _formKey,
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
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/user_man.png'),
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildCard(
                          children: [
                          TextFormField(
                              key: Key('firstNameField'),
                              controller: editFirstName,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                hintText: 'Enter your first name',
                                suffixIcon: Icon(FontAwesomeIcons.user, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                CustomInputFormatter(), // Use the custom email input formatter here
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
                                labelText: 'Last Name',
                                hintText: 'Enter your last name',
                                suffixIcon: Icon(FontAwesomeIcons.user, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                CustomInputFormatter(), 
                              ],
                              validator: (value) {
                              if (value!.isEmpty) {
                                return isEnglish ? "Please enter your last name" : "Pakilagay ang iyong apelyido" ;
                              }
                              return null;
                            },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: editEmail,
                              key: Key('emailField'),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                suffixIcon: Icon(FontAwesomeIcons.envelope, color: Colors.deepPurpleAccent),
                                border: OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                EmailInputFormatter(), // Use the custom email input formatter here
                              ],
                              validator: (value) {
                              if (value!.isEmpty) {
                                return isEnglish ? "Please enter your email" : " Pakilagay ang iyong email";
                              } else if (!RegExp(
                                  r'^[a-zA-Z]+[\w-]*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$')
                                  .hasMatch(value)) {
                                return isEnglish ? "Please enter a valid email" : "Pakilagay ng wastong email";
                              } else if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
                                return isEnglish ? "Email cannot consist of numbers only" : "Ang email ay hindi maaaring binubuo ng mga numero lamang";
                              }
                              return null;
                            },
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(bottom: 16, right: 16), 
                          child: ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            ),
                            child: Text('Save Changes', style: TextStyle(fontSize: 16)),
                          ),
                        )
                      ],
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
      setState(() {
        editFirstName.text = originalFirstName;
        editLastName.text = originalLastName;
        editEmail.text = originalEmail;
      });
    }

  }

  @override
  void dispose() {
    // Dispose the text editing controllers when the State is disposed
    editFirstName.dispose();
    editEmail.dispose();
    editLastName.dispose();

    super.dispose();
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
                Text('Confirm Changes'),
              ],
            ),
            content: Text('Are you sure you want to save the changes?'),
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
                  backgroundColor: Colors.deepPurpleAccent, 
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



  Future<void> _saveChanges() async {
    // Perform necessary logic to save changes to the Firestore database
    String id = Auth().getCurrentUserId()!;
    await FirebaseFirestore.instance.collection('userData').doc(id).update({
      'email': editEmail.text,
      'firstName': editFirstName.text,
      'lastName': editLastName.text,
    });

    // Refresh the UI with the updated data
    await getUserAccountData();
    Navigator.of(context).pop(); // Close the edit profile page
  }

  @override
  Widget build(BuildContext context) {
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
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A96E3).withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: Offset(0, 3), // Offset (vertical, horizontal)
                            ),
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 50),
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/user_man.png'),
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
                      SizedBox(height: 20),
                      Card(
                        elevation: 8, // Add elevation for a floating effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfoItem(firstName, 'First name', FontAwesomeIcons.user),
                              _buildDivider(),
                              _buildUserInfoItem(lastName, 'Last name', FontAwesomeIcons.user),
                              _buildDivider(),
                              _buildUserInfoItem(email, 'Email', FontAwesomeIcons.envelope),
                              _buildDivider(),
                              _buildLanguageItem(userLanguage,'Language', isEnglish ? 'assets/america.png' : 'assets/ph.png'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
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

  Widget _buildDivider() {
    return Divider(
      height: 8,
      color: Colors.deepPurpleAccent,
    );
  }
}


class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only alphabetic characters and disallow spaces
    final RegExp regExp = RegExp(r'^[a-zA-Z]*$');
    if (regExp.hasMatch(newValue.text)) {
      return capitalizeFirstLetter(newValue);
    }
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
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow alphabetic characters, numbers, "@" and ".", and disallow spaces
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9@.]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}