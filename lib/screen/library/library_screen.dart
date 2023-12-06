import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ebook_application/screen/home/book_details.dart';
import 'package:ebook_application/providers/shelves_provider.dart';
import 'package:ebook_application/providers/library_provider.dart';
import 'package:ebook_application/screen/library/detail_shelf_screen.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late Future myFuture;

  Future<void> fetchData(
    LibraryNotifier libraryNotifier,
    ShelvesNotifier shelvesNotifier,
  ) async {
    await libraryNotifier.fetchLibrary();
    await shelvesNotifier.fetchShelves();
  }

  @override
  void initState() {
    super.initState();

    myFuture = fetchData(
      ref.read(libraryProvider.notifier),
      ref.read(shelvesProvider.notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryNotifier = ref.watch(libraryProvider.notifier);
    final shelvesNotifier = ref.watch(shelvesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: myFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final library = ref.watch(libraryProvider);
                final shelves = ref.watch(shelvesProvider);
                return TabBarView(
                  children: [
                    RefreshIndicator(
                      onRefresh: () {
                        return fetchData(libraryNotifier, shelvesNotifier);
                      },
                      child: ListView.separated(
                        itemCount: library.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetails(
                                  book: library[index],
                                ),
                              ),
                            );
                          },
                          child: Dismissible(
                            key: Key(library[index].id),
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
                            onDismissed: (direction) async {
                              bool isUndoPressed = false;
                              final temp = library[index];
                              setState(() {
                                library.removeAt(index);
                              });

                              if (!mounted) return;
                              context.showInfoMessage(
                                "${temp.title} has been removed from your library",
                                hasUndo: true,
                                onPressed: () {
                                  setState(() {
                                    library.insert(index, temp);
                                  });
                                  isUndoPressed = true;
                                },
                                onTimeOut: () async {
                                  if (isUndoPressed) return;
                                  final shelvesNotifier =
                                      ref.watch(shelvesProvider.notifier);
                                  await libraryNotifier.remove(
                                      temp, shelvesNotifier);
                                },
                              );
                            },
                            child: SummaryInfoBook(
                              id: library[index].id,
                              title: library[index].title,
                              authors: library[index].authors,
                              description: library[index].description,
                              imgUrl: library[index].imageUrl,
                              hasOptions: true,
                            ),
                          ),
                        ),
                        separatorBuilder: (_, __) => const SizedBox(
                          height: 16,
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () {
                        return fetchData(libraryNotifier, shelvesNotifier);
                      },
                      child: ListView.builder(
                        itemCount: shelves.length,
                        itemBuilder: (context, index) {
                          String? avatarUrl;
                          if (shelves[index].bookIdAndUrl.isNotEmpty) {
                            avatarUrl = shelves[index].bookIdAndUrl.values.last;
                          }

                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailShelfScreen(
                                    shelf: shelves[index],
                                  ),
                                ),
                              ).then((shelf) {
                                if (shelf != null) {
                                  setState(() {
                                    shelves[index] = shelf;
                                  });
                                }
                              });
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  leading: avatarUrl != null
                                      ? Image.network(
                                          avatarUrl,
                                        )
                                      : Opacity(
                                          opacity: 0.3,
                                          child: SvgPicture.asset(
                                            'assets/images/book_placeholder.svg',
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                  title: Text(
                                    shelves[index].name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  subtitle: Text(
                                    '${shelves[index].bookIdAndUrl.length} books',
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
                          );
                        },
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
