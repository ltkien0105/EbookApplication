import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:ebook_application/models/user.dart';
import 'package:ebook_application/models/book.dart';

part 'book_favorites.g.dart';

const uuid = Uuid();

@HiveType(typeId: 1)
class BookFavorites {
  BookFavorites({
    required this.user,
    required this.bookFavorites,
  }) : id = uuid.v4();

  @HiveField(0)
  String id;

  @HiveField(1)
  User user;

  @HiveField(2)
  List<Book> bookFavorites;
}
