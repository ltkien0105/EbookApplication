import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/user.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(User(
          id: '',
          username: '',
          fullName: '',
          dateOfBirth: DateTime.now(),
          email: '',
        ));

  String getFormattedDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);
