import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';

class LibraryNotifier extends StateNotifier<List<Book>> {
  LibraryNotifier() : super([]);

  Future<void> fetchLibrary() async {
    final List<String> bookIDs;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await firestore.doc("libraries/${auth.currentUser!.uid}").get();
    final collection = documentSnapshot.data();

    List<Book> showedListTemp = [];
    if (collection != null) {
      bookIDs = List<String>.from(collection["books"].map((id) => id));
      await Future.forEach(bookIDs, (id) async {
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
        showedListTemp.add(bookAdded);
      });
    }
    state = showedListTemp;
  }

  Future<void> add(Book book) async {
    await firestore.doc("libraries/${auth.currentUser!.uid}").update({
      'books': FieldValue.arrayUnion([book.id])
    });

    state = [...state, book];
  }

  Future<void> remove(Book book) async {
    await firestore.doc('libraries/${auth.currentUser!.uid}').update({
      'books': FieldValue.arrayRemove([book.id])
    });

    state = state.where((element) => element.id != book.id).toList();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Book>>(
      (ref) => LibraryNotifier(),
);
