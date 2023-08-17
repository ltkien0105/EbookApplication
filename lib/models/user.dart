import 'package:hive/hive.dart';

part 'user.g.dart';


@HiveType(typeId: 1)
class User {
  User({
    required this.id,
    required this.username,
    required this.fullname,
    required this.birthday,
    required this.email,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String fullname;

  @HiveField(3)
  DateTime birthday;

  @HiveField(4)
  String email;
}
