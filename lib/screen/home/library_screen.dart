import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';
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
                print(showedList);
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
                          title: showedList[index].title,
                          authors: showedList[index].authors,
                          description: showedList[index].description,
                          imgUrl: showedList[index].imageUrl,
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 16,
                      ),
                    ),
                    ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image.network(
                                'http://books.google.com/books/content?id=ZoECAAAAYAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
                              ),
                              title: const Text(
                                'My Shelf',
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: const Text(
                                '4 books',
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
