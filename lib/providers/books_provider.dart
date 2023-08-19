import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';

class BooksNotifier extends StateNotifier<List<Book>> {
  BooksNotifier() : super([]);

  void add(Book book) {
    state = [...state, book];
  }

  void addBookList(List<Map<String, dynamic>> listBooks, {
    bool isPopular = false,
    bool isRecent = false,
  }) {
    for (var i = 0; i < listBooks.length; i++) {
      final book = listBooks[i];
      Book bookAdded = Book.fromJson(
        {
          'id': book['id'],
          'title': book['volumeInfo']['title'],
          'authors': book['volumeInfo'].containsKey('authors')
              ? book['volumeInfo']['authors']
              : [],
          'categories': book['volumeInfo'].containsKey('categories')
              ? book['volumeInfo']['categories']
              : [],
          'description': book['volumeInfo'].containsKey('description')
              ? book['volumeInfo']['description']
              : 'No description',
          'imageUrl': book['volumeInfo'].containsKey('imageLinks')
              ? book['volumeInfo']['imageLinks']['thumbnail']
              : 'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=',
        },
      );

      bookAdded.isPopular = isPopular;
      bookAdded.isRecent = isRecent;
      add(bookAdded);
    }
  }

  void update(String id,
      String title,
      String author,
      String description,
      String imageUrl,) {
    // state = [
    //   for (final book in state)
    //     if (book.id == id)
    //       Book(
    //           title: title,
    //           author: author,
    //           description: description,
    //           imageUrl: imageUrl)
    //     else
    //       book
    // ];
  }

  void remove(Book book) {
    state = state.where((m) => m.id != book.id).toList();
  }

  bool toggleBookFavoriteStatus(Book book) {
    final bookIsFavorite = state.contains(book);

    if (!bookIsFavorite) {
      add(book);
      return true;
    } else {
      remove(book);
      return false;
    }
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>(
      (ref) => BooksNotifier(),
);
