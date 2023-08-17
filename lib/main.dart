import 'package:flutter/material.dart';

//Firebase import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/theme/theme_config.dart';
import 'package:ebook_application/screen/home/home_page.dart';
import 'package:ebook_application/screen/sign_in/sign_in_screen.dart';
import 'package:ebook_application/screen/splash/splash_screen.dart';

import 'boxes/boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Init hive
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  bookBox = await Hive.openBox<Book>('bookBox');
  await Hive.openBox('settingsBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var settingsBox = Hive.box('settingsBox');
    var isFirstOpen = settingsBox.get('isFirstOpen');
    if (isFirstOpen == null) {
      settingsBox.put('isFirstOpen', true);
      isFirstOpen = true;
    }

    Widget getFirstScreen() {
      if (isFirstOpen) {
        return const SplashScreen();
      }

      if (auth.currentUser == null) {
        return const SignInScreen();
      }

      return const HomePage();
    }

    SizeConfig().init(context);

    const currentAppTheme = 'light';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ebook App',
      theme: currentAppTheme == 'light'
          ? ThemeConfig.lightTheme
          : ThemeConfig.darkTheme,
      home: getFirstScreen(),
    );
  }
}
