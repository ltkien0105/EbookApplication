import 'package:ebook_application/providers/shelves_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/models/shelf.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';

class DetailShelfScreen extends ConsumerStatefulWidget {
  const DetailShelfScreen({super.key, required this.shelf});

  final Shelf shelf;

  @override
  ConsumerState<DetailShelfScreen> createState() => _DetailShelfScreenState();
}

class _DetailShelfScreenState extends ConsumerState<DetailShelfScreen> {
  List<Book> showedList = [];

  Future<void> fetchData() async {
    showedList = await widget.shelf.fetchShelfDetails();
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
          ),
          PopupMenuButton(
            onSelected: (value) async {
              await firestore
                  .doc('libraries/${auth.currentUser!.uid}')
                  .collection('shelves')
                  .doc(widget.shelf.name)
                  .delete()
                  .then(
                (_) {
                  ref.watch(shelvesProvider.notifier).remove(widget.shelf);
                  Navigator.pop(context, false);
                },
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete this shelf'),
              ),
            ],
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
                  widget.shelf.name,
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
                  "${widget.shelf.booksIDs.length} books",
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
                future: fetchData(),
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
                          displayedInShelf: widget.shelf.name,
                          removeShelfOrLibrary: () {
                            setState(() {
                              showedList.removeAt(index);
                            });
                          },
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
