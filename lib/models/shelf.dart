import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';

class Shelf {
  final String name;
  final List<String> booksIDs;
  String? urlAvatarShelf;

  Shelf({
    required this.name,
    required this.booksIDs,
    required this.urlAvatarShelf,
  });

  Future<List<Book>> fetchShelfDetails() async {
    final List<Book> showedList = [];
    if (booksIDs.isNotEmpty) {
      await Future.forEach(booksIDs, (id) async {
        final book = await GoogleBooksApi.getBookById(id);
        final bookAdded = Book.fromJson(
          {
            'id': id,
            'title': book['title'],
            'authors': book.containsKey('authors') ? book['authors'] : [],
            'categories':
            book.containsKey('categories') ? book['categories'] : [],
            'description': book.containsKey('description')
                ? book['description']
                : 'No description',
            'imageUrl': book.containsKey('imageLinks')
                ? book['imageLinks']['thumbnail']
                : 'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
          },
        );
        showedList.add(bookAdded);
      });
    }

    return showedList;
  }

  void add(String id) {
    booksIDs.add(id);
  }

  void remove(String id) {
    booksIDs.remove(id);

    if (booksIDs.isEmpty) {
      urlAvatarShelf = null;
    }
  }
}
