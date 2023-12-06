import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';

class Shelf {
  final String name;
  Map<String, String?> bookIdAndUrl;

  Shelf({
    required this.name,
    required this.bookIdAndUrl,
  });

  Future<List<Book>> fetchShelfDetails() async {
    final List<Book> showedList = [];
    if (bookIdAndUrl.isNotEmpty) {
      await Future.forEach(bookIdAndUrl.entries, (bookId) async {
        final book = await GoogleBooksApi.getBookById(bookId.key);
        book['id'] = bookId.key;
        final bookAdded = Book.fromJson(book);
        showedList.add(bookAdded);
      });
    }

    return showedList;
  }

  void add(String id, String? url) {
    bookIdAndUrl[id] = url;
  }

  void remove(String id) {
    bookIdAndUrl.remove(id);
  }
}
