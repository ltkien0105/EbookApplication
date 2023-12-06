import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/models/shelf.dart';
import 'package:ebook_application/providers/library_provider.dart';
import 'package:ebook_application/providers/shelves_provider.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';

class DetailShelfScreen extends ConsumerStatefulWidget {
  const DetailShelfScreen({
    super.key,
    required this.shelf,
  });

  final Shelf shelf;

  @override
  ConsumerState<DetailShelfScreen> createState() => _DetailShelfScreenState();
}

class _DetailShelfScreenState extends ConsumerState<DetailShelfScreen> {
  bool hasDeleted = false;
  List<Book> showedList = [];

  @override
  void initState() {
    super.initState();

    List<Book> library = ref.read(libraryProvider);

    for (final book in library) {
      if (widget.shelf.bookIdAndUrl.keys.contains(book.id)) {
        showedList.add(book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (hasDeleted) {
          Navigator.pop(context, widget.shelf);
        }
        return Future.value(true);
      },
      child: Scaffold(
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
                    "${showedList.length} books",
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
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, __) => const SizedBox(
                      height: 8,
                    ),
                    itemCount: showedList.length,
                    itemBuilder: (_, index) => Dismissible(
                      key: Key(showedList[index].id),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 32),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete_forever,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 32),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete_forever,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) async {
                        bool isUndoPressed = false;
                        final temp = showedList[index];

                        setState(() {
                          showedList.removeAt(index);
                        });

                        if (!mounted) return;
                        context.showInfoMessage(
                          "${temp.title} has been removed from shelf ${widget.shelf.name}",
                          hasUndo: true,
                          onPressed: () {
                            setState(() {
                              showedList.insert(index, temp);
                            });
                            isUndoPressed = true;
                          },
                          onTimeOut: () async {
                            if (isUndoPressed) return;
                            ref
                                .watch(shelvesProvider.notifier)
                                .removeBookFromSpecificShelf(
                                    shelfName: widget.shelf.name,
                                    bookId: temp.id);
                            hasDeleted = true;
                          },
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
