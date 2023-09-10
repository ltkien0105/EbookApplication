import 'dart:convert';

import 'package:ebook_application/screen/home/detail_shelf_screen.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future myFuture;
  List<String> myLib = [];
  List<Book> showedList = [];
  List<Map<String, dynamic>> listShelves = [];

  Future<void> getListShelves() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .doc('libraries/${auth.currentUser!.uid}')
        .collection('shelves')
        .get();

    final listIDShelves = snapshot.docs.map((doc) => doc.id).toList();

    await Future.forEach(listIDShelves, (shelfID) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .doc('libraries/${auth.currentUser!.uid}')
          .collection('shelves')
          .doc(shelfID)
          .get();

      List<String> booksID =
          List<String>.from(snapshot.data()!['booksID'].map((id) => id));
      String urlAvatarShelf = '';
      if (booksID.isEmpty) {
        urlAvatarShelf =
            'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=';
      } else {
        final response = await http.get(Uri.parse(
            'https://www.googleapis.com/books/v1/volumes/${booksID[0]}?fields=volumeInfo(imageLinks/thumbnail)&key=$androidApiKey'));
        urlAvatarShelf =
            json.decode(response.body)["volumeInfo"]["imageLinks"]["thumbnail"];
      }
      listShelves.add({shelfID: booksID, "urlAvatarShelf": urlAvatarShelf});
    });
  }

  Future<void> fetchLibrary() async {
    DocumentSnapshot<Map<String, dynamic>> booksID =
        await firestore.doc("libraries/${auth.currentUser!.uid}").get();
    final data = booksID.data();

    if (data != null) {
      myLib = List<String>.from(data["books"].map((id) => id));
      await Future.forEach(myLib, (id) async {
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
    await getListShelves();
  }

  @override
  void initState() {
    super.initState();
    myFuture = fetchLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: myFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return TabBarView(
                  children: [
                    ListView.separated(
                      itemCount: showedList.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetails(
                                book: showedList[index],
                              ),
                            ),
                          );
                        },
                        child: SummaryInfoBook(
                          id: showedList[index].id,
                          title: showedList[index].title,
                          authors: showedList[index].authors,
                          description: showedList[index].description,
                          imgUrl: showedList[index].imageUrl,
                          hasOptions: true,
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 16,
                      ),
                    ),
                    ListView.builder(
                      itemCount: listShelves.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailShelfScreen(
                                shelfInfo: listShelves[index],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image.network(
                                listShelves[index]["urlAvatarShelf"],
                              ),
                              title: Text(
                                listShelves[index].keys.first,
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                '${listShelves[index].values.first.length} books',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_outlined,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const Divider(
                              height: 3,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
