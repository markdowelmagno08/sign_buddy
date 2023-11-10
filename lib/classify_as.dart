import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/modules/assessments/assess_one.dart';
import 'package:sign_buddy/modules/sharedwidget/page_transition.dart';
import 'package:sign_buddy/modules/widgets/back_button.dart';
import 'package:sign_buddy/modules/sharedwidget/loading.dart';
import 'package:sign_buddy/modules/widgets/internet_connectivity.dart';

class Classify extends StatefulWidget {
  const Classify({Key? key}) : super(key: key);

  @override
  State<Classify> createState() => _ClassifyState();
}

class _ClassifyState extends State<Classify> {
  final List<Map<String, dynamic>> classifyAs = [
    {'status': 'Speech Impaired'},
    {'status': 'Non-Disabled'},
  ];
  

  String? selectedClassify;
  bool loading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEnglish = true;
  

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnglish = prefs.getBool('isEnglish') ?? true;

    setState(() {
      this.isEnglish = isEnglish;
    });
  }

  void _showClassifyModal(BuildContext context) async {
  // Check for internet connectivity before showing the classification modal
  await InternetConnectivityService.checkInternetOrShowDialog(
    context: context,
    onLogin: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60
                ),
                SizedBox(height: 20),
                Text(
                  isEnglish 
                  ? 'Reminder'
                  : 'Paalala',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FiraSans'
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEnglish
                  ? "An assessment is coming up to assess your Sign Language skills."
                  : "Asahan ang pagsusuri upang suriin ang iyong kasanayan sa Pagsenyas (Sign Language)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'FiraSans'
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5BD8FF),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    if (_scaffoldKey.currentContext != null) {
                      _navigateToAssessment(_scaffoldKey.currentContext!, selectedClassify!);
                    }
                  },
                  child: Text(
                    isEnglish
                    ?'Got it'
                    : 'Tara!',
                    style: TextStyle(
                      color: Color(0xFF5A5A5A),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading(text: 'Loading . . . ')
        : Scaffold(
            key: _scaffoldKey,
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg-signbuddy.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(top: 50, left: 16),
                    child: CustomBackButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlidePageRoute(
                                page: const Classify()));
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                    child:  Text(
                      isEnglish
                      ? 'Do you classify as?'
                      : 'Ikaw ba ay?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: classifyAs.length,
                      itemBuilder: (context, index) {
                        final classify = classifyAs[index];
                        final isSelected =
                            selectedClassify == classify['status'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 30.0),
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurpleAccent
                                      : Colors.black,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    selectedClassify = classify['status'];
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                title: Text(
                                  classify['status'],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 28),
                      child: SizedBox(
                        width: 120,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: selectedClassify != null
                              ? () => _showClassifyModal(context)
                              : null,
                          style: ButtonStyle(
                            backgroundColor: selectedClassify != null
                                ? MaterialStateProperty.all<Color>(
                                    const Color(0xFF5BD8FF))
                                : MaterialStateProperty.all<Color>(
                                    const Color(0xFFD3D3D3)),
                          ),
                          child: Text(
                            isEnglish
                            ? 'Continue'
                            : 'Magpatuloy',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

    Future<void> _navigateToAssessment(BuildContext context, String classify) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Check for internet connectivity before proceeding
        await InternetConnectivityService.checkInternetOrShowDialog(
          context: context,
          onLogin: () async {
            // Store the classification data in Firestore under the user's UID
            await FirebaseFirestore.instance
                .collection('userData')
                .doc(currentUser.uid)
                .set({'classification': classify}, SetOptions(merge: true));

            setState(() => loading = true);

            // Navigate to the desired page based on the classification
            switch (classify) {
              case 'Non-Disabled':
                Navigator.push(
                    context, SlidePageRoute(page: const AssessmentOne()));
                break;
              
              case 'Speech Impaired':
                Navigator.push(
                    context, SlidePageRoute(page: const AssessmentOne()));
                break;
              // Add more cases for other classifications...

              default:
                // Handle the case when the classification is not found
                break;
            }
            // Dismiss the loading screen
            setState(() {
              loading = false;
            });
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
