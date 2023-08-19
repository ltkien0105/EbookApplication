import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:ebook_application/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';

class BookList extends ConsumerStatefulWidget {
  const BookList({super.key, this.category, this.searchTerm});

  final Category? category;
  final String? searchTerm;

  @override
  ConsumerState<BookList> createState() => _BookListState();
}

class _BookListState extends ConsumerState<BookList> {
  late final Future myFuture;
  ScrollController scrollController = ScrollController();
  int startIndex = 9;
  late List<Book> showedList;
  bool isCategory = true;

  Future<void> fetchData() async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    if (widget.category == null) isCategory = false;

    List<Map<String, dynamic>>? listBook;

    if (!isCategory) {
      listBook = await GoogleBooksApi.getBooksByFields(
        widget.searchTerm!,
        maxResults: 10,
      );
    } else {
      listBook = await GoogleBooksApi.getBooksByFields(
        '',
        searchTerm: widget.category!.searchTerm,
        searchField: SearchFields.subject,
        startIndex: startIndex,
        maxResults: 10,
      );
    }

    if (listBook != null) {
      booksNotifier.addBookList(listBook);
    }

    if (isCategory) {
      showedList = ref
          .watch(booksProvider)
          .where((book) => book.categories
              .join(' ')
              .toLowerCase()
              .contains(widget.category!.searchTerm))
          .toList();
    } else {
      final splitSearchTerm = widget.searchTerm!.split(' ');
      String joined = splitSearchTerm.map((item) => '($item)').join('|');
      String strRegex = joined;
      RegExp regex = RegExp(strRegex, caseSensitive: false);

      setState(() {
        showedList = ref
            .watch(booksProvider)
            .where((book) => regex.hasMatch(book.title))
            .toList();
      });
    }
  }

  Future<void> fetchMoreData() async {
    startIndex += 10;
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    final List<Map<String, dynamic>>? listBook;

    if (!isCategory) {
      listBook = await GoogleBooksApi.getBooksByFields(
        widget.searchTerm!,
        startIndex: startIndex,
        maxResults: 10,
      );
    } else {
      listBook = await GoogleBooksApi.getBooksByFields(
        '',
        searchTerm: widget.category!.searchTerm,
        searchField: SearchFields.subject,
        startIndex: startIndex,
        maxResults: 10,
      );
    }

    if (listBook != null) {
      booksNotifier.addBookList(listBook);
    }

    if (isCategory) {
      setState(() {
        showedList = ref
            .watch(booksProvider)
            .where((book) => book.categories
                .join(' ')
                .toLowerCase()
                .contains(widget.category!.searchTerm))
            .toList();
      });
    } else {
      final splitSearchTerm = widget.searchTerm!.split(' ');
      String strRegex = splitSearchTerm.map((item) => '($item)').join('|');
      RegExp regex = RegExp(strRegex, caseSensitive: false);

      setState(() {
        showedList = ref
            .watch(booksProvider)
            .where((book) => regex.hasMatch(book.title))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    myFuture = fetchData();
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        await fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCategory ? widget.category!.specificName : widget.searchTerm!,
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
          future: myFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: ListView.separated(
                      controller: scrollController,
                      itemCount: showedList.length + 1,
                      separatorBuilder: (context, index) => SizedBox(
                            height: getProportionateScreenHeight(6),
                          ),
                      itemBuilder: (context, index) {
                        if (index < showedList.length) {
                          return GestureDetector(
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
                              authors: showedList[index].authors,
                              title: showedList[index].title,
                              description: showedList[index].description,
                              imgUrl: showedList[index].imageUrl,
                            ),
                          );
                        } else if (index == showedList.length) {
                          return null;
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      }),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
