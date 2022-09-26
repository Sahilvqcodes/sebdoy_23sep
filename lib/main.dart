import 'package:aft/ATESTS/provider/user_provider.dart';
import 'package:aft/ATESTS/responsive/AMobileScreenLayout.dart';
import 'package:aft/ATESTS/responsive/AResponsiveLayout.dart';
import 'package:aft/ATESTS/responsive/AWebScreenLayout.dart';
import 'package:aft/ATESTS/utils/global_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAi6OvbEXLq9RidJod1bUj9XrPEY2LCBC8",
        appId: "1:463557381734:web:6b3ea8de7f9376011c27a7",
        messagingSenderId: "463557381734",
        projectId: "ft-flutter-15fa1",
        storageBucket: "ft-flutter-15fa1.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

SharedPreferences? prefs;

class MyApp extends StatelessWidget {
  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    loadPref();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData().copyWith(
            scaffoldBackgroundColor: Colors.white,
            colorScheme:
                ThemeData().colorScheme.copyWith(primary: Colors.blueGrey),
          ),
          // theme: ThemeData(
          // inputDecorationTheme: const InputDecorationTheme(
          //   labelStyle: TextStyle(color: Colors.black),
          //   hintStyle: TextStyle(color: Colors.grey),

          // scaffoldBackgroundColor: const Color.fromARGB(255, 236, 234, 234),

          title: '',
          home: ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout("0"),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      ),
    );
  }
}
