import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:ebook_application/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  late final Future myFuture;
  ScrollController scrollController = ScrollController();
  int startIndex = 9;
  late List<Book> showedList;

  Future<void> fetchData() async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    final listBookByCategory = await GoogleBooksApi.getBooksByFields(
      '',
      searchTerm: widget.category.searchTerm,
      searchField: SearchFields.subject,
      maxResults: 10,
    );

    booksNotifier.addBookList(listBookByCategory);

    showedList = ref
        .watch(booksProvider)
        .where((book) => book.categories
            .join(' ')
            .toLowerCase()
            .contains(widget.category.searchTerm!))
        .toList();
  }

  Future<void> fetchMoreData() async {
    startIndex++;
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    final listBookByCategory = await GoogleBooksApi.getBooksByFields(
      '',
      searchTerm: widget.category.searchTerm,
      searchField: SearchFields.subject,
      startIndex: startIndex,
      maxResults: 10,
    );

    booksNotifier.addBookList(listBookByCategory);

    setState(() {
      showedList = ref
          .watch(booksProvider)
          .where((book) => book.categories
              .join(' ')
              .toLowerCase()
              .contains(widget.category.searchTerm!))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    myFuture = fetchData();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        fetchMoreData();
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
          widget.category.specificName,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(25),
          ),
        ),
        centerTitle: true,
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
                          return SummaryInfoBook(
                            authors: showedList[index].authors,
                            title: showedList[index].title,
                            description: showedList[index].description,
                            imgUrl: showedList[index].imageUrl,
                          );
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
