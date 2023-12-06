import 'dart:io';
import 'package:ebook_application/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/components/input_field.dart';
import 'package:ebook_application/components/date_picker_field.dart';
import 'package:ebook_application/validator/input_validator_mixin.dart';
import 'package:ebook_application/screen/settings/change_password_screen.dart';

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
  DateTime? dateOfBirth;
  bool isLoading = false;
  bool isFirstLoad = true;

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

  Future<void> changeInfo() async {
    if (fullNameController.text != user!.displayName) {
      await user!.updateDisplayName(fullNameController.text);
    }

    if (dateOfBirth != null) {
      await firestore.doc('users/${user!.uid}').get().then((snapshot) async {
        if (snapshot.exists) {
          await firestore.doc('users/${user!.uid}').update({
            'dateOfBirth': dateOfBirth,
          });
        } else {
          await firestore.doc('users/${user!.uid}').set({
            'dateOfBirth': dateOfBirth,
          });
        }
      });
    }

    if (photoFile != null) {
      final storageRef = storage.ref();
      final avatarRef = storageRef.child('avatars/${user!.uid}.jpg');
      await avatarRef.putFile(File(photoFile!));
      final url = await avatarRef.getDownloadURL();
      await user!.updatePhotoURL(url);
    }
  }

  Future<void> applyChanges() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await changeInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    print(user);
    fullNameController = TextEditingController(
        text: user!.displayName != null ? user!.displayName! : 'No display');

    if (user!.email != null && user!.email!.isNotEmpty) {
      emailController = TextEditingController(text: user!.email);
    } else {
      if (user!.providerData[0].email != null &&
          user!.providerData[0].email!.isNotEmpty) {
        emailController =
            TextEditingController(text: user!.providerData[0].email);
      } else {
        emailController = TextEditingController(text: 'No display');
      }
    }

    firestore.doc('users/${user!.uid}').get().then((value) {
      if (value.data()?['dateOfBirth'] != null) {
        dateOfBirth = value.data()?['dateOfBirth']!.toDate();
      }
    });

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
              future: isFirstLoad
                  ? firestore.doc('users/${user!.uid}').get()
                  : null,
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
                                        final XFile? imageAvatar =
                                            await picker.pickImage(
                                                source: ImageSource.camera);

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
                                                : const Svg(
                                                        'assets/images/profile_default.svg')
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
                                        if (fullName == null ||
                                            fullName.isEmpty) {
                                          return 'Full name is required';
                                        }

                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    InputField(
                                      controller: emailController,
                                      label: 'Email',
                                      enabled: false,
                                    ),
                                    const SizedBox(height: 16),
                                    const SizedBox(
                                      width: double.infinity,
                                      height: 22,
                                      child: Text(
                                        'Date of birth',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DatePickerField(
                                      dateOfBirth: dateOfBirth,
                                      getDateOfBirth: (dateOfBirth) {
                                        this.dateOfBirth = dateOfBirth;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    if (user!.providerData[0].providerId ==
                                        'password')
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ChangePasswordScreen()));
                                        },
                                        child: const Text('Change password'),
                                      ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        isFirstLoad = false;
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await applyChanges();
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (!mounted) return;
                                        context.showInfoMessage(
                                            'Change info successfully!');
                                      },
                                      child: SizedBox(
                                        width: SizeConfig.screenWidth! * .3,
                                        child: Center(
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text('Apply Changes'),
                                        ),
                                      ),
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
