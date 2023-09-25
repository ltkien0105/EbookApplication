import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/components/date_picker_field.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> with InputValidatorMixin {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();
  final user = auth.currentUser;
  String? photoFile;
  String? photoUrl;
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late DateTime birthday;

  Future<void> _cropImage(String pathImg) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pathImg,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      cropStyle: CropStyle.circle,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          showCropGrid: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      String dir = path.dirname(croppedFile.path);
      String newPath = path.join(dir, '${user!.uid}.jpg');
      File fileRenamed = File(croppedFile.path).renameSync(newPath);
      setState(() {
        photoFile = fileRenamed.path;
      });
    }
  }

  Future<void> applyChanges() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final storageRef = storage.ref();
      final avatarRef = storageRef.child('avatars/${user!.uid}.jpg');

      // final avatarName = '${user!.uid}.jpg';
      await avatarRef.putFile(File(photoFile!));
      final url = await avatarRef.getDownloadURL();
      await firestore.doc('users/${user!.uid}').update({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'birthday': birthday,
        'imgUrl': url,
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(
        text: user!.displayName != null ? user!.displayName! : 'No display');
    emailController = TextEditingController(
        text: user!.email != null ? user!.email! : 'No display');

    if (user!.photoURL != null) {
      photoUrl = user!.photoURL!;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
          child: FutureBuilder(
              // future: userNotifier.getUser(),
              builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final XFile? imageAvatar = await picker
                                        .pickImage(source: ImageSource.camera);

                                    if (imageAvatar != null) {
                                      _cropImage(imageAvatar.path);
                                    }
                                  },
                                  child: CircleAvatar(
                                    // backgroundColor: Colors.black,
                                    radius: 40,
                                    foregroundImage: photoFile != null
                                        ? FileImage(File(photoFile!))
                                        : photoUrl != null
                                            ? CachedNetworkImageProvider(
                                                photoUrl!)
                                            : Image.asset(
                                                    'assets/images/profile_image_default.svg')
                                                as ImageProvider,
                                  ),
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
                                  controller: fullNameController,
                                  label: 'Full name',
                                  validator: (fullName) {
                                    if (fullName == null || fullName.isEmpty) {
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
                                  birthday: DateTime.now(),
                                  getBirthday: (birthday) {
                                    this.birthday = birthday;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    applyChanges();
                                  },
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
