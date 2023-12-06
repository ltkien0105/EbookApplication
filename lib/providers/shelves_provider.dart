import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/shelf.dart';

class ShelvesNotifier extends StateNotifier<List<Shelf>> {
  ShelvesNotifier() : super([]);

  Future<List<String>> fetchOnlyShelvesName() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .collection('shelves')
        .get();

    final List<String> shelvesNames =
    List<String>.from(snapshot.docs.map((doc) {
      return doc.id;
    }));

    return shelvesNames;
  }

  Future<void> fetchShelves() async {
    List<Shelf> listShelvesTemp = [];

    List<String> shelvesNames = await fetchOnlyShelvesName();

    await Future.forEach(shelvesNames, (shelfID) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .collection('shelves')
          .doc(shelfID)
          .get();

      List<String> booksIDs =
      List<String>.from(snapshot.data()!['booksID'].map((id) => id));

      Map<String, String?> booksIDAndUrl = {};

      if (booksIDs.isNotEmpty) {
        await Future.forEach(booksIDs, (bookId) async {
          final response = await http.get(Uri.parse(
              'https://www.googleapis.com/books/v1/volumes/$bookId?fields=volumeInfo(imageLinks/thumbnail)&key=$androidApiKey'));

          if (json
              .decode(response.body)
              .length != 0) {
            booksIDAndUrl[bookId] = json.decode(response.body)["volumeInfo"]
            ["imageLinks"]["thumbnail"];
          }
        });
      }

      listShelvesTemp.add(
        Shelf(
          name: shelfID,
          bookIdAndUrl: booksIDAndUrl,
        ),
      );
    });

    if (listShelvesTemp.isNotEmpty) {
      state = listShelvesTemp;
    }
  }

  void add(Shelf shelf) {
    state = [...state, shelf];
  }

  void remove(Shelf shelf) {
    state = state.where((element) => element.name != shelf.name).toList();
  }

  Future<void> addToSpecificShelf({
    required String shelfName,
    required String bookId,
    required String? imgUrl,
  }) async {
    await firestore
        .doc("libraries/${auth.currentUser!.uid}")
        .collection("shelves")
        .doc(shelfName)
        .update({
      "booksID": FieldValue.arrayUnion([bookId])
    });

    for (var shelf in state) {
      if (shelf.name == shelfName) {
        shelf.add(bookId, imgUrl);
      }
    }
  }

  Future<void> removeBookFromSpecificShelf({
    required String shelfName,
    required String bookId,
  }) async {
    await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .collection('shelves')
        .doc(shelfName)
        .update({
      'booksID': FieldValue.arrayRemove([bookId])
    });

    for (var shelf in state) {
      if (shelf.name == shelfName) {
        shelf.remove(bookId);
      }
    }
  }
}

final shelvesProvider = StateNotifierProvider<ShelvesNotifier, List<Shelf>>(
      (ref) => ShelvesNotifier(),
);
