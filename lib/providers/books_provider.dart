import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/models/book.dart';

class BooksNotifier extends StateNotifier<List<Book>> {
  BooksNotifier() : super([]);

  void add(Book book) {
    state = [...state, book];
  }

  void addBookList(
    List<Map<String, dynamic>> listBooks, {
    bool isPopular = false,
    bool isRecent = false,
  }) {
    for (final book in listBooks) {
      final bookAdded = Book.fromJson(book);
      bookAdded.isPopular = isPopular;
      bookAdded.isRecent = isRecent;
      add(bookAdded);
    }
  }

  void updateFavoriteStatus(Book bookUpdated) {
    state = [
      for (final book in state)
        if (book.id == bookUpdated.id) bookUpdated else book
    ];
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

  List<Book> removeDuplicate(List<Book> listBook) {
    for (var i = 0; i < listBook.length; i++) {
      final currentBook = listBook[i];
      for (var j = i; j < listBook.length; j++) {
        final nextBook = listBook[j];
        if (currentBook.id == nextBook.id && i != j) {
          listBook.remove(nextBook);
        }
      }
    }

    return listBook;
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>(
  (ref) => BooksNotifier(),
);
