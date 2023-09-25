import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/shelf.dart';

class ShelvesNotifier extends StateNotifier<List<Shelf>> {
  ShelvesNotifier() : super([]);

  Future<void> fetchShelves() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .collection('shelves')
        .get();

    final shelvesIDs = snapshot.docs.map((doc) => doc.id).toList();
    List<Shelf> listShelvesTemp = [];
    await Future.forEach(shelvesIDs, (shelfID) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .collection('shelves')
          .doc(shelfID)
          .get();

      List<String> booksIDs =
          List<String>.from(snapshot.data()!['booksID'].map((id) => id));
      String? urlAvatarShelf;

      if (booksIDs.isNotEmpty) {
        final response = await http.get(Uri.parse(
            'https://www.googleapis.com/books/v1/volumes/${booksIDs[0]}?fields=volumeInfo(imageLinks/thumbnail)&key=$androidApiKey'));

        if (json.decode(response.body).length != 0) {
          urlAvatarShelf = json.decode(response.body)["volumeInfo"]
              ["imageLinks"]["thumbnail"];
        }
      }

      listShelvesTemp.add(
        Shelf(
          name: shelfID,
          booksIDs: booksIDs,
          urlAvatarShelf: urlAvatarShelf,
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
}

final shelvesProvider = StateNotifierProvider<ShelvesNotifier, List<Shelf>>(
  (ref) => ShelvesNotifier(),
);
