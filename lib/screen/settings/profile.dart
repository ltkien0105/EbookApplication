import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/providers/users_provider.dart';
import 'package:ebook_application/components/date_picker_field.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> with InputValidatorMixin {
  final formKey = GlobalKey<FormState>();

  late TextEditingController fullnameController;
  late TextEditingController emailController;
  late DateTime birthday;

  void getBirthday(DateTime chosenBirthday) {
    birthday = chosenBirthday;
  }

  bool validate() {
    if (formKey.currentState!.validate()) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.watch(usersNotifierProvider.notifier);
    final user = ref.watch(usersNotifierProvider);

    void assignValue() {
      fullnameController = TextEditingController(text: user.fullname);
      emailController = TextEditingController(text: user.email);
      birthday = user.birthday;
    }

    Future<void> applyChanges() async {
      if (!validate()) return;

      // if (client.auth.currentUser!.email != emailController.text) {
      //   await client.auth.updateUser(
      //     user_supabase.UserAttributes(
      //       email: emailController.text,
      //     ),
      //   );
      // }

      // await client.from('users').update({
      //   'fullname': fullnameController.text,
      //   'birthday': birthday.toIso8601String(),
      //   'email': emailController.text,
      // }).eq('username', user.username);

      user.fullname = fullnameController.text;
      user.birthday = birthday;
      user.email = emailController.text;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
          child: FutureBuilder(
              future: userNotifier.getUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  assignValue();
                  return CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black,
                                      radius: 40,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    InputField(
                                      label: 'Username',
                                      initialValue: user.username,
                                      enabled: false,
                                    ),
                                    const SizedBox(height: 16),
                                    InputField(
                                      controller: fullnameController,
                                      label: 'Fullname',
                                      validator: (fullname) {
                                        if (fullname == null ||
                                            fullname.isEmpty) {
                                          return 'Full name is required';
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    InputField(
                                      controller: emailController,
                                      label: 'Email',
                                      validator: (email) {
                                        if (email == null || email.isEmpty) {
                                          return 'Email is required';
                                        }

                                        if (isEmailValid(email)) return null;

                                        return 'Enter a valid email';
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const SizedBox(
                                      width: double.infinity,
                                      height: 22,
                                      child: Text(
                                        'Birthday',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DatePickerField(
                                      birthday: user.birthday,
                                      getBirthday: getBirthday,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: applyChanges,
                                      child: const Text('Apply Changes'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
