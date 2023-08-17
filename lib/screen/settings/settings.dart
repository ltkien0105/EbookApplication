import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:ebook_application/constants.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/screen/settings/profile.dart';
import 'package:ebook_application/screen/settings/favorites.dart';
import 'package:ebook_application/screen/sign_in/sign_in_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _pushSignInScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SignInScreen(),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().disconnect();
      await auth.signOut();
    } on PlatformException catch (_) {
      await auth.signOut();
    } finally {
      _pushSignInScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: const Text('Favorites'),
            leading: Icon(
              Icons.favorite_border,
              size: getProportionateScreenWidth(30),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Favorite(),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: getProportionateScreenHeight(0.5),
          ),
          ListTile(
            title: const Text('About'),
            leading: Icon(
              Icons.info_outline,
              size: getProportionateScreenWidth(30),
            ),
          ),
          Divider(
            height: 1,
            thickness: getProportionateScreenHeight(0.5),
          ),
          ListTile(
            title: const Text('Log out'),
            onTap: () {
              _signOut();
            },
            leading: Icon(
              Icons.logout,
              size: getProportionateScreenWidth(30),
            ),
          ),
          Divider(
            height: 1,
            thickness: getProportionateScreenHeight(0.5),
          ),
          ListTile(
            title: const Text('Profiles'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Profile(),
                ),
              );
            },
            leading: Icon(
              Icons.account_circle,
              size: getProportionateScreenWidth(30),
            ),
          ),
        ],
      ),
    );
  }
}
