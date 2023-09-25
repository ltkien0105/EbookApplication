import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/user.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(User(
          id: '',
          username: '',
          fullname: '',
          birthday: DateTime.now(),
          email: '',
        ));

  Future<void> getUser() async {
    // final user = await client
    //     .from('users')
    //     .select('username, fullname, birthday, email')
    //     .eq('email', client.auth.currentUser!.email);
    //
    // final date = user[0]['birthday'].toString().split('-');
    //
    // final birthday = DateTime(
    //   int.parse(date[0]),
    //   int.parse(date[1]),
    //   int.parse(date[2]),
    // );
    //
    //
    // state.username = user[0]['username'];
    // state.fullname = user[0]['fullname'];
    // state.birthday = birthday;
    // state.email = user[0]['email'];
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);
