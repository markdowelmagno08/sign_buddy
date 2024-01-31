import 'package:shared_preferences/shared_preferences.dart';


// saves the language of the user locally
Future<void> setLanguage(bool isEnglish) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isEnglish', isEnglish);
}