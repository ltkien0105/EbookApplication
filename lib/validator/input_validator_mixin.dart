mixin InputValidatorMixin {
  bool isPasswordValid(String password) => password.length >= 8;

  bool isEmailValid(String email) {
    RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return regex.hasMatch(email);
  }

  bool isPhoneValid(String phone) {
    RegExp regex = RegExp(r'^0[0-9]{9}$');

    return regex.hasMatch(phone);
  }
}

