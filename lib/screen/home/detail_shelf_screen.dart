import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:flutter/material.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';

class DetailShelfScreen extends StatefulWidget {
  const DetailShelfScreen({super.key, required this.shelfInfo});

  final Map<String, dynamic> shelfInfo;

  @override
  State<DetailShelfScreen> createState() => _DetailShelfScreenState();
}

class _DetailShelfScreenState extends State<DetailShelfScreen> {
  late Future myFuture;
  final List<Book> showedList = [];

  Future<void> fetchData() async {
    final List<String> listID =
        List<String>.from(widget.shelfInfo.values.first.map((id) => id));

    if (listID.isNotEmpty) {
      await Future.forEach(listID, (id) async {
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

    myFuture = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.shelfInfo.keys.first,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  "${widget.shelfInfo.values.first.length} books",
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Divider(
                height: 3,
                thickness: 1,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 16,
              ),
              FutureBuilder(
                future: myFuture,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Expanded(
                      child: ListView.separated(
                        separatorBuilder: (_, __) => const SizedBox(
                          height: 8,
                        ),
                        itemCount: showedList.length,
                        itemBuilder: (_, index) => SummaryInfoBook(
                          id: showedList[index].id,
                          title: showedList[index].title,
                          authors: showedList[index].authors,
                          description: showedList[index].description,
                          imgUrl: showedList[index].imageUrl,
                          hasOptions: true,
                        ),
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
