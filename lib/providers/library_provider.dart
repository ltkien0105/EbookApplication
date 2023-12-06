import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook_application/providers/shelves_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';

class LibraryNotifier extends StateNotifier<List<Book>> {
  LibraryNotifier() : super([]);

  Future<void> fetchLibrary() async {
    final List<String> bookIDs;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await firestore.doc("libraries/${auth.currentUser!.uid}").get();

    if (!documentSnapshot.data()!.containsKey('books')) {
      await firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .set({'books': []});
    }
    final collection = documentSnapshot.data();

    List<Book> showedListTemp = [];
    if (collection != null) {
      bookIDs = List<String>.from(collection["books"].keys.map((id) => id));
      await Future.forEach(bookIDs, (id) async {
        final book = await GoogleBooksApi.getBookById(id);
        book['id'] = id;
        final bookAdded = Book.fetchSpecificBook(book);
        showedListTemp.add(bookAdded);
      });
    }
    state = showedListTemp;
  }

  Future<void> add({required Book book, String? shelf}) async {
    if (shelf == null) {
      firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .get()
          .then((snapshot) {
        if (!snapshot.exists) {
          firestore.doc('libraries/${auth.currentUser!.uid}').set({
            'books': {book.id: []}
          });
        } else {
          firestore
              .doc('libraries/${auth.currentUser!.uid}')
              .update({'books.${book.id}': []});
        }
      });
    } else {
      await firestore.doc("libraries/${auth.currentUser!.uid}").update({
        'books.${book.id}': FieldValue.arrayUnion([shelf])
      });
    }

    state = [...state, book];
  }

  Future<void> remove(Book book, ShelvesNotifier shelvesNotifier) async {
    final libraryDocumentSnapshot =
        await firestore.doc('libraries/${auth.currentUser!.uid}').get();

    final shelves = List<String>.from(libraryDocumentSnapshot
        .data()!['books'][book.id]
        .map((shelf) => shelf));

    if (shelves.isNotEmpty) {
      Future.forEach(shelves, (shelf) async {
        await shelvesNotifier.removeBookFromSpecificShelf(
          shelfName: shelf,
          bookId: book.id,
        );
      });
    }

    await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .update({'books.${book.id}': FieldValue.delete()});

    state = state.where((element) => element.id != book.id).toList();
  }

  Future<void> removeById(String bookId) async {
    final libraryDocumentSnapshot =
        await firestore.doc('libraries/${auth.currentUser!.uid}').get();

    final shelves = List<String>.from(
        libraryDocumentSnapshot.data()!['books'][bookId].map((shelf) => shelf));

    if (shelves.isNotEmpty) {
      Future.forEach(shelves, (shelf) async {
        await firestore
            .doc('libraries/${auth.currentUser!.uid}')
            .collection('shelves')
            .doc(shelf)
            .update({
          'booksID': FieldValue.arrayRemove([bookId])
        });
      });
    }

    await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .update({'books.$bookId': FieldValue.delete()});
    state = state.where((element) => element.id != bookId).toList();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Book>>(
  (ref) => LibraryNotifier(),
);
