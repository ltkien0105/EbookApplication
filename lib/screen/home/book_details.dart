import 'dart:convert';

import 'package:ebook_application/providers/library_provider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/constants.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/providers/shelves_provider.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';

import 'components/category_box.dart';

class BookDetails extends ConsumerStatefulWidget {
  const BookDetails({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends ConsumerState<BookDetails> {
  late List<Book> showedList;
  late Future myFuture;
  bool isFavorite = false;
  bool isFirstLoad = false;
  bool isExpanded = false;

  List<String> getCategoryHandled() {
    if (widget.book.categories.isNotEmpty) {
      List<String> listCategory = widget.book.categories.map((category) {
        if (category.contains('(')) {
          return category.substring(0, category.indexOf('(') - 1);
        }

        if (category.contains('/')) {
          return category.substring(0, category.indexOf('/') - 1);
        }

        return category;
      }).toList();
      listCategory = listCategory.toSet().toList();
      return listCategory.length > 4
          ? listCategory.sublist(0, 4)
          : listCategory;
    }
    return [];
  }

  Future<void> fetchData() async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    List<Map<String, dynamic>>? listBook;

    listBook = await GoogleBooksApi.getBooksByFields(
      '',
      searchTerm: widget.book.authors[0],
      searchField: SearchFields.inauthor,
      maxResults: 5,
    );

    if (listBook != null) {
      booksNotifier.addBookList(listBook);
    }

    showedList = ref
        .watch(booksProvider)
        .where((book) => book.authors.contains(widget.book.authors[0]))
        .toList();
    showedList = booksNotifier.removeDuplicate(showedList);
    showedList.removeAt(0);
  }

  Future<void> checkFavoriteStatus() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.doc('libraries/${auth.currentUser!.uid}').get();

    if (snapshot.exists) {
      List<String> listFavorites =
          List<String>.from(snapshot['books'].keys.map((book) => book));

      isFavorite = listFavorites.contains(widget.book.id);
      isFirstLoad = true;
    }
  }

  void updateFavoriteStatus(bool isFavoriteCheck) {
    setState(() {
      isFavorite = isFavoriteCheck;
    });
  }

  Future<Map<String, dynamic>> getDownloadInfo(String bookId) async {
    Uri uri = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes/$bookId?fields=accessInfo(epub,pdf)');
    final response = await http.get(uri);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    myFuture = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    String showAuthors = widget.book.authors.join(', ');
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                updateFavoriteStatus(!isFavorite);
                final libraryNotifier = ref.watch(libraryProvider.notifier);
                final shelvesNotifier = ref.watch(shelvesProvider.notifier);

                if (isFavorite) {
                  libraryNotifier.add(book: widget.book);
                } else {
                  libraryNotifier.remove(widget.book, shelvesNotifier);
                }
              },
              child: FutureBuilder(
                future: !isFirstLoad ? checkFavoriteStatus() : null,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done ||
                      snapshot.connectionState == ConnectionState.none) {
                    if (isFavorite) {
                      return Icon(
                        Icons.favorite,
                        size: getProportionateScreenWidth(30),
                      );
                    } else {
                      return Icon(
                        Icons.favorite_border_outlined,
                        size: getProportionateScreenWidth(30),
                      );
                    }
                  }

                  return Icon(
                    Icons.favorite_border_outlined,
                    size: getProportionateScreenWidth(30),
                  );
                },
              ),
            ),
          ),
          IconButton(
              onPressed: () async {
                Uri uri = Uri.parse(
                    'https://www.googleapis.com/books/v1/volumes/${widget.book.id}?fields=volumeInfo/previewLink');
                final response = await http.get(uri);
                final previewLink = json.decode(response.body);
                await launchUrl(
                  Uri.parse(previewLink['volumeInfo']['previewLink']),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const Icon(
                Icons.preview,
                size: 30,
              )),
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Select download format'),
                      content: FutureBuilder(
                          future: getDownloadInfo(widget.book.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              final downloadInfo = snapshot.data;
                              String? acsmLink;
                              bool isEpubAvailable = downloadInfo?['accessInfo']
                                  ['epub']['isAvailable'] as bool;
                              bool isPdfAvailable = downloadInfo?['accessInfo']
                                  ['pdf']['isAvailable'] as bool;

                              if (isEpubAvailable &&
                                  downloadInfo?['accessInfo']['epub']
                                          ['acsTokenLink'] !=
                                      null) {
                                acsmLink = downloadInfo?['accessInfo']['epub']
                                    ['acsTokenLink'];
                              } else if (isPdfAvailable &&
                                  downloadInfo?['accessInfo']['pdf']
                                          ['acsTokenLink'] !=
                                      null) {
                                acsmLink = downloadInfo?['accessInfo']['pdf']
                                    ['acsTokenLink'];
                              } else {
                                acsmLink = null;
                              }

                              bool canDownloadEpub = downloadInfo?['accessInfo']
                                      ['epub']['downloadLink'] !=
                                  null;

                              bool canDownloadPdf = downloadInfo?['accessInfo']
                                      ['pdf']['downloadLink'] !=
                                  null;

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canDownloadEpub)
                                    TextButton(
                                        onPressed: () async {
                                          await launchUrl(
                                            Uri.parse(
                                                downloadInfo?['accessInfo']
                                                    ['epub']['downloadLink']),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Text('EPUB')),
                                  if (canDownloadPdf)
                                    TextButton(
                                        onPressed: () async {
                                          await launchUrl(
                                            Uri.parse(
                                                downloadInfo?['accessInfo']
                                                    ['pdf']['downloadLink']),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Text('PDF')),
                                  if (acsmLink != null)
                                    TextButton(
                                        onPressed: () async {
                                          await launchUrl(Uri.parse(acsmLink!));
                                        },
                                        child: const Text('ACSM')),
                                  if (!canDownloadEpub &&
                                      !canDownloadPdf &&
                                      acsmLink == null)
                                    const Text('No download available')
                                ],
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          }),
                    );
                  },
                );
              },
              icon: const Icon(Icons.download)),
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'add shelves') {
                showDialog(
                    context: context,
                    builder: (_) {
                      final shelves = ref.watch(shelvesProvider);
                      final shelvesNames = shelves.map((shelf) => shelf.name);
                      return AlertDialog(
                        title: const Text(
                          'Add or remove this book from shelves...',
                        ),
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: SizeConfig.screenHeight! * .05,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: shelvesNames.map((shelfName) {
                              return StatefulBuilder(
                                builder: (
                                  BuildContext context,
                                  void Function(void Function()) setState,
                                ) {
                                  List<String?> listContainThisBook =
                                      shelves.map((shelf) {
                                    if (shelf.bookIdAndUrl.keys
                                        .contains(widget.book.id)) {
                                      return shelf.name;
                                    }
                                  }).toList();

                                  return ListTile(
                                    leading: Checkbox(
                                      value: listContainThisBook
                                          .contains(shelfName),
                                      onChanged: (newValue) async {
                                        if (newValue == true) {
                                          await firestore
                                              .doc(
                                                  'libraries/${auth.currentUser!.uid}')
                                              .get()
                                              .then((documentSnapshot) async {
                                            if (documentSnapshot.data() ==
                                                null) {
                                              await firestore
                                                  .doc(
                                                      'libraries/${auth.currentUser!.uid}')
                                                  .set({'books': []});
                                            }
                                          });

                                          await firestore
                                              .doc(
                                                  'libraries/${auth.currentUser!.uid}')
                                              .update(
                                            {
                                              'books.${widget.book.id}':
                                                  FieldValue.arrayUnion(
                                                      [shelfName])
                                            },
                                          );

                                          updateFavoriteStatus(true);

                                          await ref
                                              .watch(shelvesProvider.notifier)
                                              .addToSpecificShelf(
                                                shelfName: shelfName,
                                                bookId: widget.book.id,
                                                imgUrl: widget.book.imageUrl,
                                              );
                                          setState(() {});
                                        } else {
                                          await firestore
                                              .doc(
                                                  'libraries/${auth.currentUser!.uid}')
                                              .update({
                                            'books.${widget.book.id}':
                                                FieldValue.arrayRemove(
                                                    [shelfName])
                                          });

                                          await ref
                                              .watch(shelvesProvider.notifier)
                                              .removeBookFromSpecificShelf(
                                                shelfName: shelfName,
                                                bookId: widget.book.id,
                                              );
                                          setState(() {});
                                        }
                                      },
                                      activeColor: Colors.red,
                                    ),
                                    title: Text(shelfName),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add shelves',
                child: Text('Add to shelves'),
              ),
            ],
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight! * .25,
                  child: Row(
                    children: [
                      Container(
                          height: double.infinity,
                          width: getProportionateScreenWidth(150),
                          color: Colors.yellow,
                          child: widget.book.imageUrl != null
                              ? Image.network(
                                  widget.book.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : SvgPicture.asset(
                                  'assets/images/book_placeholder.svg',
                                  fit: BoxFit.cover,
                                )),
                      SizedBox(
                        width: getProportionateScreenWidth(8),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.book.title,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getProportionateScreenWidth(20),
                                  fontWeight: FontWeight.bold),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(4),
                            ),
                            Text(
                              showAuthors,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: getProportionateScreenWidth(15),
                              ),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(8),
                            ),
                            Expanded(
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 1 / .3,
                                mainAxisSpacing:
                                    getProportionateScreenHeight(8),
                                crossAxisSpacing:
                                    getProportionateScreenWidth(4),
                                children: getCategoryHandled()
                                    .map((category) =>
                                        CategoryBox(category: category))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: double.infinity,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Book Description',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Divider(
                        height: getProportionateScreenHeight(16),
                        thickness: getProportionateScreenHeight(2),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(8),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          widget.book.description,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(15),
                          ),
                          maxLines: isExpanded ? null : 8,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.screenWidth,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          icon: Icon(isExpanded
                              ? Icons.arrow_circle_up
                              : Icons.arrow_circle_down),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(8),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight! * .5,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'More from this author',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Divider(
                        height: getProportionateScreenHeight(16),
                        thickness: getProportionateScreenHeight(2),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(8),
                      ),
                      FutureBuilder(
                        future: myFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) => SizedBox(
                                  height: getProportionateScreenHeight(8),
                                ),
                                itemCount: showedList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookDetails(
                                            book: showedList[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: SummaryInfoBook(
                                      id: showedList[index].id,
                                      title: showedList[index].title,
                                      authors: showedList[index].authors,
                                      description:
                                          showedList[index].description,
                                      imgUrl: showedList[index].imageUrl,
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    ],
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
